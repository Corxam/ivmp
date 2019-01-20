

local func = {}

function func.printT(text)
	local time = os.date("*t")
	print(("%02d:%02d:%02d -> %s"):format(time.hour, time.min, time.sec, text))
end


return func