# frozen_string_literal: true

# app/controllers/api/v1/projects_controller.rb
module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_project, only: %i[show update destroy update_status activity]
      before_action :authorize_project_access!, only: %i[show update destroy update_status activity]

      # GET /api/v1/projects
      def index
        @projects = policy_scope(Project)
                    .includes(:owner, :members, :milestones)
                    .recent

        @projects = apply_filters(@projects)

        render json: ProjectSerializer.new(@projects, include: %w[owner milestones])
                     .serializable_hash
                     .merge(meta: pagination_meta(@projects)),
               status: :ok
      end

      # GET /api/v1/projects/:id
      def show
        render json: ProjectSerializer.new(@project, include: %w[owner members milestones comments])
                     .serializable_hash,
               status: :ok
      end

      # POST /api/v1/projects
      def create
        @project = current_user.owned_projects.build(project_params)

        if @project.save
          render json: ProjectSerializer.new(@project).serializable_hash,
                 status: :created, location: api_v1_project_url(@project)
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_content
        end
      end

      # PATCH/PUT /api/v1/projects/:id
      def update
        if @project.update(project_params)
          render json: ProjectSerializer.new(@project).serializable_hash, status: :ok
        else
          render json: { errors: @project.errors.full_messages }, status: :unprocessable_content
        end
      end

      # DELETE /api/v1/projects/:id
      def destroy
        @project.discard!
        render json: { deleted: true, id: @project.id }, status: :ok
      end

      # PATCH /api/v1/projects/:id/update_status
      def update_status
        ActiveRecord::Base.transaction do
          @project.update!(status: params[:status])
          @project.recalculate_progress! if params[:recalculate].present?
        end
        render json: { id: @project.id, status: @project.status }, status: :ok
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      rescue ArgumentError => e
        render json: { errors: [e.message] }, status: :unprocessable_content
      end

      # GET /api/v1/projects/:id/activity
      def activity
        logs = @project.activity_logs
                       .includes(:user)
                       .order(created_at: :desc)
                       .paginate(page: params[:page], per_page: 25)
        render json: {
          data: logs.map do |l|
            { id: l.id, action: l.action, metadata: l.metadata, occurred_at: l.created_at }
          end,
          meta: pagination_meta(logs)
        }, status: :ok
      end

      private

      def set_project
        @project = Project.find(params[:id])
      end

      def authorize_project_access!
        authorize @project
      end

      def project_params
        params.expect(
          project: [:name, :client, :description, :status,
                    :progress, :color, :deadline, :category,
                    { tag_list: [] }]
        )
      end

      def apply_filters(scope)
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.by_client(params[:client]) if params[:client].present?
        scope = scope.where('name ILIKE ?', "%#{params[:q]}%") if params[:q].present?
        scope.paginate(page: params[:page], per_page: params[:per_page] || 25)
      end

      def pagination_meta(collection)
        {
          total: collection.total_entries,
          page: collection.current_page,
          per_page: collection.per_page,
          pages: collection.total_pages
        }
      end
    end
  end
end
