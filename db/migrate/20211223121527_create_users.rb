class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :employee_number
      t.string :uid
      t.datetime :designated_work_start_time
      t.datetime :designated_work_end_time
      t.boolean :sperior 

      t.timestamps
    end
  end
end
