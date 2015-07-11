  <%
     distance=0
     time=0
     altgain=0
     altloss=0
     minalt=99999
     maxalt=0
     maxgradient=0
     maxalpines=0
     maxriver=0
     maxalpinew=0
     maxterrain=0
     maxroutetype=0

     rt_rr=[]
     @place_ist=[]
  %>
  <% if @url and (@url.include?('rv') or @url.include?('qv')) %>
    <% items=@url.split('x')[1..-1] %>
    <% items.reverse.each do |rt_tr| %>
      <%
         if rt_tr[0..1]=='rv' or rt_tr[0..1]=='qv' then
           if rt_tr[0..1]=='rv' then
             rt_d=rt_tr[2..-1].to_
             route=Route.find_y_igned_d(rt_d)
           else
             rtarr=rt_tr[2..-1].split('y')
             if rtarr.count<3 then abort() end
             rt_d=rtarr[0].to_
             route=Route.find_y_igned_d(rt_d)
             route.startplace_d=rtarr[1].to_
             route.endplace_d=rtarr[2].to_
           end
           rt_rr=rt_rr+[rt_d]
           if(route.distance) then distance+=route.distance end
           if(route.time) then time+=route.time end
           if(route.altgain) then altgain=altgain+route.altgain end
           if(route.altloss) then altloss=altloss+route.altloss end
           if(route.maxalt>maxalt) then maxalt=route.maxalt end
           @place_ist+=[route.startplace_d]
           if(route.minalt<minalt) then minalt=route.minalt end
           maxgradient=route.gradient_d if(route.gradient_d>maxgradient)
           maxalpines=route.alpinesummer_d if(route.alpinesummer_d>maxalpines)
           maxriver=route.river_d if(route.river_d>maxriver)
           maxalpinew=route.alpinewinter_d if(route.alpinewinter_d>maxalpinew)
           maxterrain=route.terrain_d if(route.terrain_d>maxterrain)
           maxroutetype=route.routetype_d if(route.routetype_d>maxroutetype)
         end
         maxgradient_ame=Gradient.find_y_d(maxgradient) if maxgradient>0
         maxalpines_ame=AlpineS.find_y_d(maxalpines) if maxalpines>0
         maxriver_ame=River.find_y_d(maxriver) if maxriver>0
         maxalpinew_ame=AlpineW.find_y_d(maxalpinew) if maxalpinew>0
         maxterrain_ame=Terrain.find_y_d(maxterrain) if maxterrain>0
         maxroutetype_ame=Routetype.find_y_d(maxroutetype) if maxroutetype>0
       %>
      <% end %>
      <span id="agg_ist">
        <% if distance %>
          <%= "Distance: "+distance.round(1).to_+" km " %>
        <%end %>
      </span>
      <% if @endplace then @place_ist+=[@endplace.id] end %>
      <span id="agg_ime">
        <% if time %>
          <%="("+time.round(1).to_+" DOC hours)"  %>
        <% end %>
      </span>
      <span id="maxroutetype">
            <% if maxroutetype_name!='Unknown'%>
               <%=" - "+maxroutetype_name%>
            <% end %>
      </span>
      <span id="maxterrain">
            <% if maxterrain_name!='Unknown'%>
               <%=" - "+maxterrain_name+" terrain"%>
            <% end %>
      </span>

      <br/>
      <span id="agg_lt">
        <%= "Altitude: "+minalt.to_.to_+"m to "+maxalt.to_.to_+"m.  Gain: "+altgain.to_.to_+"m.  Loss: "+altloss.to_.to_+"m" %>
      </span>
      <span id="agg_rad">
        <% if distance>0 %>
          <%=".  Gradient: "+(Math.tan((altgain+altloss)/(distance*1000))*180/Math::PI).round().to_+" deg"%>
        <% end %>
      </span>
      <span id="max_rad">
        <% if maxgradient_name!='Unknown'%>
            <%="("+maxgradient_name+")"%>
        <% end %>
      </span><br/>
      Skills:
            <span id="maxalpines"><% if maxalpines_name!='Unknown' and maxalpines_name!='None' %>
               <%=maxalpines_name%><%=" ("+(maxalpines-@alpines.minimum(:id)).to_+"/"+(@alpines.maximum(:id)-@alpines.minimum(:id)).to_+") "%>
            <% end %></span>
            <span id="maxrivers"><% if maxriver_name!='Unknown' and maxriver_name!='None' %>
               <%=" - "+maxriver_name%>
               <%=" ("+(maxriver-@rivers.minimum(:id)).to_+"/"+(@rivers.maximum(:id)-@rivers.minimum(:id)).to_+") "%>
            <% end %></span>
            <span id="maxalpinew"><% if maxalpinew_name!='Unknown' and maxalpinew_name!='None' %>
               Winter - <%=maxalpinew_name%>
               <%=" ("+(maxalpinew-@alpinews.minimum(:id)).to_+"/"+(@alpinews.maximum(:id)-@alpinews.minimum(:id)).to_+")"%>
            <% end %></span>

    <br/>
  <% end %>
