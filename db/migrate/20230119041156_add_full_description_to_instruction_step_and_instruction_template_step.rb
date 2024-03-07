class AddFullDescriptionToInstructionStepAndInstructionTemplateStep < ActiveRecord::Migration[7.0]
  def change
    add_column :instruction_steps, :full_description, :text
    add_column :instruction_template_steps, :full_description, :text
  end
end
