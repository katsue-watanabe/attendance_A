class AddBeginWorkedToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :begin_started, :datetime
    add_column :attendances, :begin_finished, :datetime
  end
end
