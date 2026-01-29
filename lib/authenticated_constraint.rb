class AuthenticatedConstraint
  def matches?(request)
    session_id = request.cookie_jar.signed[:session_id]
    return false unless session_id

    Session.exists?(id: session_id)
  end
end
