class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :designated_work_start_time
      t.datetime :designated_work_end_time
      t.datetime :overwork_end_time
      t.boolean :next_day
      t.string :note
      t.string :superior_confirmation
      t.string :select_superior_for_overwork
      t.string :confirm_superior_for_overtime
      t.string :process_content
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
