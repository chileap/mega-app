class CreateInstructionTemplateSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :instruction_template_steps do |t|
      t.references :meal_template, null: false, foreign_key: true
      t.integer :position, null: false
      t.text :description

      t.timestamps
    end
  end
end
