class CreateTimeLineStatuses < ActiveRecord::Migration
  def change
    create_table :time_line_statuses do |t|
      t.string :status
      t.integer :authentication_id

      t.timestamps
    end
  end
end
