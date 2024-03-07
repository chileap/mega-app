class CreateInstructionSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :instruction_steps do |t|
      t.references :meal, null: false, foreign_key: true
      t.integer :position, null: false
      t.text :description

      t.timestamps
    end
  end
end
