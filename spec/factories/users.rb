FactoryGirl.define do
  factory :user, class: User do |f|
    f.github_uid   "00000"
    f.name         "anonymous"
    f.repo_url     "no_url"
    f.blog_repo    "no_repo"
    f.blog_repo_id "1234"
    f.nickname     "anon"

  end
end
