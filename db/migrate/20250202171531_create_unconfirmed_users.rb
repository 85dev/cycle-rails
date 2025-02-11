class CreateUnconfirmedUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :unconfirmed_users do |t|
      t.string :email, null: false
      t.string :access_code
      t.datetime :access_code_sent_at

      t.timestamps
    end
  end
end
