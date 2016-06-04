class AddBlogRepoIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :blog_repo_id, :string
  end
end
