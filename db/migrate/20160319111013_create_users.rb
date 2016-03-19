class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string    :full_name,          :null => false
      t.integer   :facebookId,           :limit => 8
      t.string    :email,               :null => false
      t.boolean   :is_admin,            :default => false
      t.string    :crypted_password,    :null => false                # optional, see below
      t.string    :password_salt,       :null => false                # optional, but highly recommended
      t.string    :persistence_token,   :null => false                # required
      t.string    :session_id,          :limit => 40
      t.string    :single_access_token, :null => false                # optional, see Authlogic::Session::Params
      t.string    :perishable_token,    :null => false                # optional, see Authlogic::Session::Perishability
      t.datetime  :last_login_at                                      # optional
      t.datetime  :current_login_at

      t.timestamps
    end
  end
end
