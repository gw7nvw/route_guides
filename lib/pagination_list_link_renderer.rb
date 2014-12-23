class PaginationListLinkRenderer < WillPaginate::ActionView::LinkRenderer 

  protected

    def page_number(page)
      if @options[:order] and @options[:order]=='latest' then
        unless page == current_page
          link(@collection.page(page).first.updated_at.strftime("%b%y"), page, :rel => rel_value(page))
        else
          tag(:em, @collection.page(page).first.updated_at.strftime("%b%y"), :class => "current")
        end

      else
        unless page == current_page
          link(@collection.page(page).first.name[0..2], page, :rel => rel_value(page))
        else
          tag(:em, @collection.page(page).first.name[0..2], :class => "current")
        end
      end
    end

    def previous_or_next_page(page, text, classname)
      if page
        link(text, page, :class => classname)
      else
        tag(:span, text, :class => classname + ' disabled')
      end
    end

    def html_container(html)
      tag(:div, html, container_attributes)
    end

end
