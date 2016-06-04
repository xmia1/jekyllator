class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :github_uid
      t.string :name
      t.string :repo_url
      t.string :blog_repo

      t.timestamps null: false
    end
  end
end
