--
-- CLIPBOARD MANIPULATION
--

-- contents of clipboard saved to ~/Downloads as a formatted json file
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Z", function()
	hs.execute("~/bin/sctj", true)
end)

--
-- WINDOW MANAGEMENT
--

-- disable window move/resize animations
hs.window.animationDuration = 0

-- preferred window size for the "C" hotkey (pixels)
local preferred_width = 801
local preferred_height = 605

-- pixel step for the arrow-key grow/shrink hotkeys
local tweak_amount = 60

-- minimum window size for the shrink hotkeys (pixels)
local min_width = 570
local min_height = 570

-- movable windows are not popovers, floating panels,
-- modal dialogs, invisible helper windows, or minimized
local function movableWindows(app)
	local result = {}
	for _, win in ipairs(app:allWindows()) do
		if win:isStandard() and not win:isMinimized() then
			result[#result + 1] = win
		end
	end
	return result
end

-- focused window takes the full screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "M", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local screen_frame = focused_window:screen():frame()

	focused_window:setFrame(screen_frame)
end)

-- all the frontmost application's windows on the focused window's screen
-- take the full screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, ",", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local focused_screen = focused_window:screen()
	local app = hs.application.frontmostApplication()
	local screen_frame = focused_screen:frame()

	for _, win in ipairs(movableWindows(app)) do
		if win:screen() == focused_screen then
			win:setFrame(screen_frame)
		end
	end
end)

-- all the frontmost application's windows on the focused window's screen
-- centered on that screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "A", function()
	local app = hs.application.frontmostApplication()

	local screen_frame, window_frame, wide, high

	for _, win in ipairs(movableWindows(app)) do
		screen_frame = win:screen():frame()
		window_frame = win:frame()
		wide = window_frame.w
		high = window_frame.h
		window_frame.x = screen_frame.x + ((screen_frame.w / 2) - (wide / 2))
		window_frame.y = screen_frame.y + ((screen_frame.h / 2) - (high / 2))
		win:setFrame(window_frame)
	end
end)

-- focused window sized to set dimensions and centered
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "C", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local window_frame = focused_window:frame()
	local screen_frame = focused_window:screen():frame()
	local wide = window_frame.w
	local high = window_frame.h

	-- first, try centering the widnow at its current size
	window_frame.x = screen_frame.x + ((screen_frame.w / 2) - (wide / 2))
	window_frame.y = screen_frame.y + ((screen_frame.h / 2) - (high / 2))

	-- some apps may not size to exactly wide x high, so check before and after
	local before_frame = focused_window:frame()
	focused_window:setFrame(window_frame)
	local after_frame = focused_window:frame()

	-- if the window was already centered, resize to the preferred size
	if before_frame == after_frame and (wide ~= preferred_width or high ~= preferred_height) then
		window_frame.x = screen_frame.x + ((screen_frame.w / 2) - (preferred_width / 2))
		window_frame.y = screen_frame.y + ((screen_frame.h / 2) - (preferred_height / 2))
		window_frame.w = preferred_width
		window_frame.h = preferred_height

		focused_window:setFrame(window_frame)
	elseif before_frame == after_frame and wide == preferred_width and high == preferred_height then
		-- if the window was already sized and centered, grow it to full screen height
		window_frame.y = screen_frame.y
		window_frame.h = screen_frame.h

		focused_window:setFrame(window_frame)
	end
end)

-- move the passed window to the passed screen
local function moveWindowToScreen(window, screen)
	-- shrink the window if it's bigger than the target screen
	local target_screen_frame = screen:frame()
	local window_frame = window:frame()
	local wide = window_frame.w
	local high = window_frame.h
	if wide > target_screen_frame.w then
		wide = target_screen_frame.w
	end
	if high > target_screen_frame.h then
		high = target_screen_frame.h
	end
	-- center the frame in the new screen
	window_frame.x = target_screen_frame.x + ((target_screen_frame.w / 2) - (wide / 2))
	window_frame.y = target_screen_frame.y + ((target_screen_frame.h / 2) - (high / 2))
	window_frame.w = wide
	window_frame.h = high

	window:setFrame(window_frame)
end

-- return the screen after the passed one in allScreens() order (wrapping
-- from last to first), or nil if there's only one screen
local function nextScreen(screen)
	local all_screens = hs.screen.allScreens()
	local count = #all_screens
	if count <= 1 then
		return nil
	end
	for i = 1, count do
		if all_screens[i] == screen then
			return all_screens[i % count + 1]
		end
	end
	return nil
end

-- focused window moved to the next screen (if any) and centered
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "N", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local target_screen = nextScreen(focused_window:screen())
	if target_screen then
		moveWindowToScreen(focused_window, target_screen)
	end
end)

-- all the frontmost application's windows moved to the next screen (if any) and centered
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "B", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local target_screen = nextScreen(focused_window:screen())
	if target_screen then
		-- step through the windows and move them to the next screen
		local app = hs.application.frontmostApplication()

		for _, win in ipairs(movableWindows(app)) do
			moveWindowToScreen(win, target_screen)
		end
	end
end)

-- snap the passed window to the passed edge of its screen; if the window is
-- already on that edge (or always_fill is true), fill the corresponding half
-- of the screen instead
-- edge: "left" | "right" | "top" | "bottom"
local function snapWindowToEdge(win, edge, always_fill)
	local window_frame = win:frame()
	local screen_frame = win:screen():frame()

	local at_edge = always_fill == true
		or (edge == "left" and window_frame.x == screen_frame.x)
		or (edge == "right" and window_frame.x + window_frame.w == screen_frame.x + screen_frame.w)
		or (edge == "top" and window_frame.y == screen_frame.y)
		or (edge == "bottom" and window_frame.y + window_frame.h == screen_frame.y + screen_frame.h)

	if at_edge then
		-- fill the corresponding half of the screen
    local half_width = math.floor(screen_frame.w / 2)
    local half_height = math.floor(screen_frame.h / 2)
		if edge == "left" then
			window_frame.x = screen_frame.x
			window_frame.y = screen_frame.y
			window_frame.w = half_width
			window_frame.h = screen_frame.h
		elseif edge == "right" then
			window_frame.x = screen_frame.x + screen_frame.w - half_width
			window_frame.y = screen_frame.y
			window_frame.w = half_width
			window_frame.h = screen_frame.h
		elseif edge == "top" then
			window_frame.x = screen_frame.x
			window_frame.y = screen_frame.y
			window_frame.w = screen_frame.w
			window_frame.h = half_height
		else -- "bottom"
			window_frame.x = screen_frame.x
			window_frame.y = screen_frame.y + screen_frame.h - half_height
			window_frame.w = screen_frame.w
			window_frame.h = half_height
		end
	else
		-- just move to the edge of the screen
		if edge == "left" then
			window_frame.x = screen_frame.x
		elseif edge == "right" then
			window_frame.x = screen_frame.x + screen_frame.w - window_frame.w
		elseif edge == "top" then
			window_frame.y = screen_frame.y
		else -- "bottom"
			window_frame.y = screen_frame.y + screen_frame.h - window_frame.h
		end
	end

	win:setFrame(window_frame)
end

-- focused window moves to left edge of screen, then fills the left half of the screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "H", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	snapWindowToEdge(focused_window, "left")
end)

-- move the focused window and all other windows belonging to the same app and on the
-- same screen to the left half of the screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "U", function()

	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local focused_screen = focused_window:screen()

	local app = hs.application.frontmostApplication()

	for _, win in ipairs(movableWindows(app)) do
		if win:screen() == focused_screen then
			snapWindowToEdge(win, "left", true)
		end
	end
end)

-- focused window moves to right edge of screen, then fills the right half of the screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "L", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	snapWindowToEdge(focused_window, "right")
end)

-- move the focused window and all other windows belonging to the same app and on the
-- same screen to the right half of the screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "O", function()

	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local focused_screen = focused_window:screen()

	local app = hs.application.frontmostApplication()

	for _, win in ipairs(movableWindows(app)) do
		if win:screen() == focused_screen then
			snapWindowToEdge(win, "right", true)
		end
	end
end)

-- focused window moves to top edge of screen, then fills the top half of the screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "K", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	snapWindowToEdge(focused_window, "top")
end)

-- focused window moves to bottom edge of screen, then fills the bottom half of the screen
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "J", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	snapWindowToEdge(focused_window, "bottom")
end)

-- focused window's width increased by set amount
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local window_frame = focused_window:frame()
	local screen_frame = focused_window:screen():frame()

	-- when on the right edge, shift left by the full amount so the window
	-- expands leftward instead of past the right edge of the screen
	local on_right_edge = window_frame.x + window_frame.w == screen_frame.x + screen_frame.w
	local left_shift = on_right_edge and tweak_amount or tweak_amount / 2

	window_frame.x = math.max(window_frame.x - left_shift, screen_frame.x)
	window_frame.w = math.min(window_frame.w + tweak_amount, screen_frame.w)

	focused_window:setFrame(window_frame)
end)

-- focused window's width decreased by set amount
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local window_frame = focused_window:frame()
	local screen_frame = focused_window:screen():frame()

	-- allow shrinking at least two steps below the half-screen size
	local effective_min_width = math.floor(math.min(min_width, (screen_frame.w / 2) - (tweak_amount * 2)))
	local new_width = math.max(window_frame.w - tweak_amount, effective_min_width)

	-- stick to the edges of the screen
	local window_not_on_left_edge = window_frame.x ~= screen_frame.x
	local window_on_right_edge = window_frame.x + window_frame.w == screen_frame.x + screen_frame.w
	local window_center = window_frame.x + (window_frame.w / 2)

	if window_not_on_left_edge and window_on_right_edge then
		window_frame.x = screen_frame.x + screen_frame.w - new_width
	elseif window_not_on_left_edge then
		window_frame.x = window_center - (new_width / 2)
	end

	window_frame.w = new_width

	focused_window:setFrame(window_frame)
end)

-- focused window's height increased by set amount
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Up", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local window_frame = focused_window:frame()
	local screen_frame = focused_window:screen():frame()

	-- when on the bottom edge, shift up by the full amount so the window
	-- expands upward instead of past the bottom edge of the screen
	local on_bottom_edge = window_frame.y + window_frame.h == screen_frame.y + screen_frame.h
	local top_shift = on_bottom_edge and tweak_amount or tweak_amount / 2

	window_frame.y = math.max(window_frame.y - top_shift, screen_frame.y)
	window_frame.h = math.min(window_frame.h + tweak_amount, screen_frame.h)

	focused_window:setFrame(window_frame)
end)

-- focused window's height decreased by set amount
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Down", function()
	local focused_window = hs.window.focusedWindow()
	if not focused_window then return end
	local window_frame = focused_window:frame()
	local screen_frame = focused_window:screen():frame()

	-- allow shrinking at least two steps below the half-screen size
	local effective_min_height = math.floor(math.min(min_height, (screen_frame.h / 2) - (tweak_amount * 2)))
	local new_height = math.max(window_frame.h - tweak_amount, effective_min_height)

	-- stick to the edges of the screen
	local window_not_on_top_edge = window_frame.y ~= screen_frame.y
	local window_on_bottom_edge = window_frame.y + window_frame.h == screen_frame.y + screen_frame.h
	local window_center = window_frame.y + (window_frame.h / 2)

	if window_on_bottom_edge then
		window_frame.y = screen_frame.y + screen_frame.h - new_height
	elseif window_not_on_top_edge then
		window_frame.y = window_center - (new_height / 2)
	end

	window_frame.h = new_height

	focused_window:setFrame(window_frame)
end)
