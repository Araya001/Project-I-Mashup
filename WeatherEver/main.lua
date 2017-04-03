local JSON = require("json")
local cx,cy
local name,temp,main,desc,sunrise,sunset
local icon,imgIcon
local resp
local sunriseIcon, sunsetIcon, tempIcon, rain, clound

function reqTranslateListener(event)
	if (event.phase == "ended") then
		audio.play(audio.loadSound(event.response.filename,system.DocumentsDirectory))
	end
end

function reqTranslate(text, lang)
	network.download(
		"https://translate.google.com/translate_tts?ie=UTF-&&q="..text.."&tl="..lang.."&client=tw-ob",
		"GET",
		reqTranslateListener,
		{},
		math.random(15000)..".mp3",
		system.DocumentsDirectory	
	)
end


local function handleRequest( event )
	if not(event.isError)then
		resp = JSON.decode(event.response)
		name.text = resp["name"]
		temp.text = resp["main"]["temp"].."°C"
		main.text = resp["weather"][1]["main"]
		desc.text = resp["weather"][1]["description"]
		temperature = string.format("%.1f",resp["main"]["temp"])
		sunriseTime = os.date("%X",resp["sys"]["sunrise"])
		sunsetTime = os.date("%X",resp["sys"]["sunset"])
		sunrise.text = sunriseTime
		sunset.text = sunsetTime
		icon = resp["weather"][1]["icon"]
	

		if(imgIcon)then
		imgIcon:removeSelf()
		imgIcon = nil
		end
		imgIcon = display.newImage(icon..".png",cx,330)
		imgIcon:scale(1,1)

		if(main.text == "Rain") then
			if(rain)then
				rain:removeSelf()
			rain = nil
		end
			rain = display.newImage("rain1.png",cx,cy)
			reqTranslate("Today is Raining day Temperature is"..temperature.."Please take care yourself", "en")
		elseif(main.text == "Clouds") then
			if(rain)then
			rain:removeSelf()
			rain = nil
		end
			reqTranslate("Today is Cloudy day Temperature is"..temperature.."Don't for get to bring umbrella to the outside", "en")
			rain = display.newImage("cloud1.png",cx,cy)
		else
			reqTranslate("Today is a Good day Temperature is"..temperature.."Enjoy", "en")
			rain:removeSelf()
			rain = nil
		end

	end
end
local function loadWeather()
	local cid = province_id[id]
	network.request(
	"http://api.openweathermap.org/data/2.5/weather?id="..cid.."&appid=753a241c48ea4d7db09280dc103f5136&units=metric",
	"GET",
	handleRequest
	)	
end

local function nameListener(event)
	if(event.phase == "ended")then
	id = (id % #province_id)+1
	loadWeather()
	end
end

province_id = {"1152631","1906686","1151253","1606375", "1605277","1152467"}
id = 1



cx =display.contentCenterX
cy = display.contentCenterY

backgroundImage = display.newImage("bg4.jpg",cx,cy)
backgroundImage.x = cx
backgroundImage.y = 270

name = display.newText("",cx,30,"Agency FB",30)
temp = display.newText("",180,120,"Agency FB",75)
main = display.newText("",cx,200,"Agency FB",40)
desc = display.newText("",cx,240,"Agency FB",25)
sunrise = display.newText("",180,435,"Agency FB",25)
sunset = display.newText("",140,475,"Agency FB",25)
sunriseIcon = display.newImage("sunrise.png",120,435)
sunriseIcon:scale(0.5,0.5)
sunsetIcon = display.newImage("sunset.png",200,480)
sunsetIcon:scale(0.7,0.7)
tempIcon = display.newImage("tempress.png",60,115)
tempIcon:scale(0.7,0.7)
loadWeather()
name:addEventListener("touch",nameListener)