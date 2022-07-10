class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :restarted_at
      t.datetime :refinished_at      
      t.time :overwork_end_time
      t.boolean :next_day
      t.boolean :overwork_next_day
      t.string :note      
      t.string :overwork_status
      t.string :overwork_approval_status
      t.string :attendance_change_status
      t.string :attendance_change_check_status
      t.string :one_month_approval_status
      t.string :one_month_approval_check_status
      t.string :process_content
      t.string :superior_confirmation
      t.string :superior_notice_confirmation
      t.string :superior_attendance_change_confirmation
      t.string :superior_attendance_change_approval_confirmation
      t.string :superior_month_notice_confirmation
      t.string :superior_month_approval_confirmation
      t.boolean :is_check
      t.boolean :change_check
      t.boolean :approval_check
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
