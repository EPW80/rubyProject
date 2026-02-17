class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string  :name,        null: false
      t.string  :client,      null: false
      t.text    :description
      t.string  :status,      null: false, default: 'backlog'
      t.integer :progress,    null: false, default: 0
      t.string  :color
      t.datetime :deadline
      t.string  :category
      t.string  :tag_list, array: true, default: []
      t.datetime :discarded_at
      t.timestamps
    end

    add_index :projects, :status
    add_index :projects, :discarded_at
    add_index :projects, :tag_list, using: :gin
  end
end
