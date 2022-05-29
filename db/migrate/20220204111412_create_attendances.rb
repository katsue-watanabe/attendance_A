class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at      
      t.time :overwork_end_time
      t.boolean :next_day
      t.boolean :overwork_next_day
      t.string :note
      t.string :superior_confirmation
      t.string :overwork_status
      t.string :process_content
      t.boolean :is_check
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
