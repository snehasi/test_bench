def all_repos
  [TS.repo_base] + TS.repo_list
end

def bugmark_tracker_name_for(repo)
  repo.gsub("/", "-").upcase
end

def iora_tracker_name_for(type, repo)
  case type.to_s
  when 'github' then repo
  when 'yaml' then "/tmp/ytrack_#{repo.gsub("/", "_")}"
  else raise "Unrecognized type (#{type})}"
  end
end