class CreateSalaries < ActiveRecord::Migration[8.1]
  def change
    create_table :salaries do |t|
      t.references :employee, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.date :effective_from, null: false
      t.date :effective_to
      t.string :reason

      t.timestamps
    end
    add_index :salaries, [:employee_id, :effective_to]
    add_index :salaries, [:employee_id, :effective_from]
  end
end
