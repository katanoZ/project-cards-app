class MembershipLogsCallbacks
  def after_create(membership)
    content = "#{membership.project_user.name}さんが#{membership.user.name}さんをこのプロジェクトに招待しました"
    Log.create!(content: content, project: membership.project)
  end

  def after_update(membership)
    return unless membership.saved_change_to_join? && membership.join
    content = "#{membership.user.name}さんがこのプロジェクトに参加しました"
    Log.create!(content: content, project: membership.project)
  end
end
