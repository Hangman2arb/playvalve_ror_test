module V1
  class UsersController < ApplicationController
    def check_status
      idfa = params[:idfa]
      rooted_device = params[:rooted_device]
      country_code = request.headers['CF-IPCountry']
      ip = request.remote_ip

      return render json: { error: 'Missing or incorrect parameters' }, status: :bad_request unless idfa.present? && [true, false].include?(rooted_device)

      if country_banned?(country_code) || rooted_device
        user = User.find_by(idfa: idfa)
        if user
          ip_info = check_ip_and_set_status(user)
          user.banned!
          log_integrity(user, ip, rooted_device, ip_info, country_code)
        end
        return render json: { ban_status: 'banned' }, status: :ok
      end

      user = User.find_or_initialize_by(idfa: idfa)
      was_banned = user.banned?

      if user.new_record? || !was_banned
        ip_info = check_ip_and_set_status(user)
        log_integrity(user, ip, rooted_device, ip_info, country_code) if user.new_record? || (user.changed? && user.banned?)
        user.save if user.changed?
      end

      render json: { ban_status: user.unbanned? ? 'not_banned' : 'banned' }, status: :ok
    end

    private

    def country_banned?(country_code)
      !country_code.present? || !$redis.smembers('allowed_countries').include?(country_code)
    end

    def check_ip_and_set_status(user)
      ip_info = VpnApiService.check_ip(request.remote_ip)
      if ip_info['security']['vpn'] || ip_info['security']['proxy'] || ip_info['security']['tor']
        user.ban_status = :banned
      else
        user.ban_status = :unbanned
      end
      ip_info
    end

    def log_integrity(user, ip, rooted_device, ip_info, country_code)
      IntegrityLog.create(
        idfa: user.idfa,
        ban_status: user.ban_status,
        ip: ip,
        rooted_device: rooted_device,
        country: country_code,
        proxy: ip_info['security']['proxy'],
        vpn: ip_info['security']['vpn']
      )
    end
  end
end
