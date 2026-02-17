class CreateMilestones < ActiveRecord::Migration[7.2]
  def change
    create_table :milestones do |t|
      t.references :project, null: false, foreign_key: true
      t.string   :title,     null: false
      t.text     :description
      t.boolean  :completed, null: false, default: false
      t.datetime :due_date
      t.timestamps
    end
  end
end
