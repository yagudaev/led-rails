class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.integer :pid
      t.string :program
      t.json :args, default: {}

      t.timestamps
    end
  end
end
