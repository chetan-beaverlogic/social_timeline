class ChangeColumnTypeofTimeLineStatusesTable < ActiveRecord::Migration
  def change
    change_column :time_line_statuses, :status, :text
  end
end
