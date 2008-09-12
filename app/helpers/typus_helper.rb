module TypusHelper

  ##
  # Applications list on the dashboard
  #
  def applications

    html = "<div id=\"list\">"

    if Typus.applications.size == 0
      return display_error("There are not defined applications in config/typus.yml")
    end

    Typus.applications.each do |module_name|

      enabled = false

      html_module = <<-HTML
        <table>
          <tr>
            <th colspan="2">#{module_name}</th>
          </tr>
      HTML

      Typus.modules(module_name).each do |model|
        if @current_user.models.include? model

          html_module << "<tr class=\"#{cycle('even', 'odd')}\">\n"
          html_module << "<td>#{link_to model.titleize.pluralize, "/admin/#{model.tableize}"}<br /></td>\n"

          html_module << "<td align=\"right\" valign=\"bottom\"><small>"
          html_module << "#{link_to 'Add', "/admin/#{model.tableize}/new"}" if @current_user.can_create? model
          html_module << "</small></td>\n"

          html_module << "</tr>"

          enabled = true

        end
      end

      html_module << <<-HTML
        </table>
        <br />
        <div style="clear"></div>
      HTML
      
      html << html_module if enabled
      
    end

    html << "</div>"

#  rescue Exception => error
#    display_error(error)
  end

  def typus_block(name)
    render :partial => "typus/#{name}" rescue nil
  end

  def display_error(error)
    "<div id=\"flash\" class=\"error\"><p>#{error}</p></div>"
  end

  def page_title
    crumbs = []
    crumbs << Typus::Configuration.options[:app_name]
    crumbs << params[:model] << params[:action]
    return crumbs.compact.map { |x| x.titleize }.join(" &rsaquo; ")
  end

  def header
    "<h1>#{Typus::Configuration.options[:app_name]} <small>#{link_to "View site", '/', :target => 'blank'}</small></h1>"
  end

  def login_info
    html = <<-HTML
      <ul>
        <li>Logged as #{link_to @current_user.full_name_with_role, :controller => 'admin/typus_users', :action => 'edit', :id => @current_user.id}</li>
        <li>#{link_to "Logout", typus_logout_url}</li>
      </ul>
    HTML
    return html
  end

  def display_flash_message
    flash_types = [ :error, :warning, :notice ]
    flash_type = flash_types.detect{ |a| flash.keys.include?(a) } || flash.keys.first
    if flash_type
      "<div id=\"flash\" class=\"%s\"><p>%s</p></div>" % [flash_type.to_s, flash[flash_type]]
    end
  end

  def display_error(error)
    log_error error
    "<div id=\"flash\" class=\"error\"><p>#{error}</p></div>"
  end

  ##
  #
  #
  def log_error(exception)
    ActiveSupport::Deprecation.silence do
        logger.fatal(
        "Typus Error:\n\n#{exception.class} (#{exception.message}):\n    " +
        exception.backtrace.join("\n    ") +
        "\n\n"
        )
    end
  end

end