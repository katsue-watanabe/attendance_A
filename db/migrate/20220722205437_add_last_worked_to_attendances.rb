class AddLastWorkedToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :last_started, :datetime
    add_column :attendances, :last_finished, :datetime
  end
end
