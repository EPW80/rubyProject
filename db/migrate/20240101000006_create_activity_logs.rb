class CreateActivityLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :activity_logs do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user,    null: true,  foreign_key: true
      t.string :action, null: false
      t.jsonb  :metadata, default: {}
      t.timestamps
    end

    add_index :activity_logs, :created_at
  end
end
