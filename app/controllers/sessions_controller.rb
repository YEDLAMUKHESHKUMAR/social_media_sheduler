class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email].downcase)

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Welcome back, #{user.first_name}!"
      redirect_to dashboard_path
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You have been logged out."
    redirect_to login_path
  end

  def omniauth
    auth = request.env["omniauth.auth"]

    uid = auth.uid
    token = auth.credentials.token
    secret = auth.credentials.secret
    email = auth.info.email 

    full_name = auth.info.name.to_s.strip
    first_name, last_name = parse_full_name(full_name)

    user = User.find_by(twitter_uid: uid) || (email && User.find_by(email: email))

    if user
      user.update(
        twitter_uid: uid,
        twitter_token: token,
        twitter_secret: secret,
        first_name: user.first_name.presence || first_name,
        last_name: user.last_name.presence || last_name
      )
    else
      user = User.new(
        email: email.presence || "#{uid}@twitter.com", 
        twitter_uid: uid,
        twitter_token: token,
        twitter_secret: secret,
        first_name: first_name,
        last_name: last_name,
        password: SecureRandom.hex(16) 
      )
      user.save
    end

    if user.persisted?
      session[:user_id] = user.id
      flash[:notice] = "Successfully connected with Twitter!"
      redirect_to dashboard_path
    else
      flash[:alert] = "There was an error connecting with Twitter: #{user.errors.full_messages.to_sentence}"
      redirect_to login_path
    end
  end

  private

  def parse_full_name(full_name)
    names = full_name.split(" ")
    if names.length > 1
      first_name = names.first
      last_name = names[1..-1].join(" ")
    else
      first_name = names.first || "User"
      last_name = ""
    end
    [first_name, last_name]
  end
end
