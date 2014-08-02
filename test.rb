def full_title(page_title)
	base_title = "NZ Route Guides"
	if page_title.empty?
	base_title
	else
	"#{base_title} | #{page_title}"
	end
	end

def routes_from_to(placea, placeb)

  maxLegCount=20

  here=Place.find_by_id(placea)
  validDest=Array.new
  placeSoFar=[]
  routeSoFar=[]
  placeSoFar[0]=[here.id]
  routeSoFar[0]=[]
  goodPath=[]
  goodRoute=[]
  destFound=1
  legCount=0
  goodPathCount=0

  while destFound>0 and legCount<maxLegCount do

    legCount+=1
    loopCount=0
    nextPlaceSoFar=[]
    nextRouteSoFar=[]
    placeSoFar.each do |thisPath|

      #get latets place added to list
      here=Place.find_by_id(thisPath[0])
      destFound=0

      #add each route to hash
      here.adjoiningRoutes.each do |ar|
	if ar.endplace_id==here.id then nextDest=ar.startplace_id
	else nextDest=ar.endplace_id
	end

	if nextDest==placeb then
        	goodPath[goodPathCount]=[nextDest]+thisPath
                goodRoute[goodPathCount]=[ar.id]+routeSoFar[loopCount]
                goodPathCount+=1
        else
          if !thisPath.include? nextDest then
                nextRouteSoFar[destFound]=[ar.id]+routeSoFar[loopCount]
                nextPlaceSoFar[destFound]=[nextDest]+thisPath
                destFound+=1
          end
        end
      end #end of 'each adjoining route' for thisPlace
      loopCount+=1
    end # end of for each flace so far
    #replace placesSpFar with new list of latest destinatons found
    placeSoFar=nextPlaceSoFar
    routeSoFar=nextRouteSoFar 
  end #end of while we get results & don;t exceed max hop count

  goodRoute
end
