local esp_library = {
    settings = {
        master_switch = false;
        boxes = {
            enabled = false;
            color  = Color3.fromRGB(255,255,255);
            gradient = {true, Color3.fromRGB(255,255,255), Color3.fromRGB(119, 120, 255)};
            filled = {
                enabled = true;
                transparency = 0.75;
                color = Color3.fromRGB(255,255,255);
            },
            animate = true;
            animatespeed = 250;
            bounding = true;
        };

        names = {
            enabled = false;
            color = Color3.fromRGB(255,255,255);
            outline = true;
            type = "lower"; -- lower, HIGHER
            layout = "Center" -- Center, Left, Right
        };

        flags = {
            distance = {false, Color3.fromRGB(255,255,255)};
            tool = {false, Color3.fromRGB(255,255,255)};
            state = {false, Color3.fromRGB(255,255,255)};
        };

        health_bars = {
            enabled = false;
            color = Color3.fromRGB(255, 255, 255);
            use_health_color = false;
            gradient = {true, Color3.fromRGB(255,255,255), Color3.fromRGB(119, 120, 255)};
            text = true;
            offset = 6;
            thickness = 1;
            tween_speed = 0.1;
        };
    };
};

local workspace, run_service, players, core_gui, lighting, user_input_service = cloneref(game:GetService("Workspace")), cloneref(game:GetService("RunService")), cloneref(game:GetService("Players")), cloneref(game:GetService("CoreGui")), cloneref(game:GetService("Lighting")), game:GetService("UserInputService");
local localplayer, camera = players.LocalPlayer, workspace.CurrentCamera;
local world_to_viewport = camera.WorldToViewportPoint;
local inf = math.huge;

local _tick = tick();
local rotation_angle = 90;

local obj = {
    inew = Instance.new;

    v2new = Vector2.new;
    v3new = Vector3.new;
    cframenew = CFrame.new;
    u2new = UDim2.new;
    u2formscale = UDim2.fromScale;

    floor = math.floor;
    max = math.max;
    abs = math.abs;
    tan = math.tan;
    rad = math.rad;
    
    rgb = Color3.fromRGB;
    hsv = Color3.fromHSV;
}

local funcs = {}; do
    function funcs:create(class, properties)
        local instance = obj.inew(class);

        for property, value in properties do
            instance[property] = value;
        end;

        return instance;
    end;

    function funcs:vector_2_floor(position)
        return obj.v2new(obj.floor(position.X), obj.floor(position.Y))
    end

    function funcs:cframe_to_viewport(cframe, floor)
        local position, visible = world_to_viewport(camera, cframe * (cframe - cframe.p):ToObjectSpace(camera.CFrame - camera.CFrame.p).p)
        if floor then
            position = funcs:vector_2_floor(position)
        end
        return position, visible
    end    

    function funcs:get_box_size(position, cframe)
        if esp_library.settings.boxes.bounding then
            local size = obj.v3new(4, 5.75, 1.5)
    
            local x = funcs:cframe_to_viewport(cframe * obj.cframenew(size.X, 0, 0))
            local y = funcs:cframe_to_viewport(cframe * obj.cframenew(0, size.Y, 0))
            local z = funcs:cframe_to_viewport(cframe * obj.cframenew(0, 0, size.Z))
    
            local SizeX = obj.max(obj.abs(position.X - x.X), obj.abs(position.X - z.X))
            local SizeY = obj.max(obj.abs(position.Y - y.Y), obj.abs(position.Y - x.Y))
    
            return obj.v2new(math.clamp(obj.floor(SizeX), 3, inf), math.clamp(obj.floor(SizeY), 6, inf))
        else
            local distance = (camera.CFrame.p - cframe.p).magnitude
            local factor = 1 / ((distance / 3) * math.tan(math.rad(camera.FieldOfView / 2)) * 2) * 1000
            return obj.v2new(math.clamp(obj.floor(factor * 1.3), 3, inf), math.clamp(obj.floor(factor * 2.1), 6, inf))
        end
    end
end;

do
    do
        if not isfile("proggyclean.ttf") then
            writefile("proggyclean.ttf", game:HttpGet("https://raw.githubusercontent.com/f1nobe7650/other/main/ProggyClean.ttf"));
        end
        
        getsynasset = getcustomasset or getsynasset
        Font = setreadonly(Font, false);
        function Font:Register(Name, Weight, Style, Asset)
            if not isfile(Name .. ".font") then
                if not isfile(Asset.Id) then
                    writefile(Asset.Id, Asset.Font);
                end;
                --
                local Data = {
                    name = Name,
                    faces = {{
                        name = "Regular",
                        weight = Weight,
                        style = Style,
                        assetId = getsynasset(Asset.Id);
                    }}
                };
                --
                writefile(Name .. ".font", game:GetService("HttpService"):JSONEncode(Data));
                return getsynasset(Name .. ".font");
            else 
                warn("Font already registered");
            end;
        end;
        --
        function Font:GetRegistry(Name)
            if isfile(Name .. ".font") then
                return getsynasset(Name .. ".font");
            end;
        end;
    
        Font:Register("proggyclean", 400, "normal", {Id = "proggyclean.ttf", Font = ""});
    end
    
    local text_font = Font.new(Font:GetRegistry("proggyclean"));

    local screen_gui = funcs:create("ScreenGui", {
        Parent = core_gui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    local remove_esp = function(player)
        if screen_gui:FindFirstChild(player.Name) then
            screen_gui[player.Name]:ClearAllChildren();
            screen_gui[player.Name]:Destroy();
        end;
    end;

    local create_esp = function(player)
        local player_folder = funcs:create("Folder", {Parent = screen_gui, Name = player.Name})
        local box_main = funcs:create("Frame", {Visible = false; Parent = player_folder, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0});
        local box_outline = funcs:create("UIStroke", {Parent = box_main, Enabled = false, Transparency = 0, Color = Color3.fromRGB(255, 255, 255)});
        local box_gradient = funcs:create("UIGradient", {Rotation = 90,Parent = box_main, Enabled = false, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, esp_library.settings.boxes.gradient[2]), ColorSequenceKeypoint.new(1, esp_library.settings.boxes.gradient[3])}})
        local box_outline_gradient = funcs:create("UIGradient", {Rotation = 90,Parent = box_outline, Enabled = false, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, esp_library.settings.boxes.gradient[2]), ColorSequenceKeypoint.new(1, esp_library.settings.boxes.gradient[3])}})
        local nametag = funcs:create("TextLabel", {Name = "nametag", BackgroundTransparency = 1, RichText = true, TextXAlignment = Enum.TextXAlignment.Center; BorderSizePixel = 0, Visible = false, Parent = player_folder, TextSize = 12, FontFace = text_font, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255), AutomaticSize = Enum.AutomaticSize.X});
        local behind_healthbar = funcs:create("Frame", {BackgroundTransparency = 1, BorderSizePixel = 0, Parent = player_folder, Visible = false});
        local health_bar_outline = funcs:create("UIStroke", {Parent = behind_healthbar,Transparency = 0, Color = Color3.fromRGB(0, 0, 0)});
        local inside_healthbar = funcs:create("Frame", {Parent = behind_healthbar, AnchorPoint = obj.v2new(0,1), Position = UDim2.new(0,0,1,0), Size = UDim2.new(1,0,0,0)})
        local health_bar_gradient = funcs:create("UIGradient", {Rotation = 90,Parent = inside_healthbar, Enabled = false, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, esp_library.settings.health_bars.gradient[2]), ColorSequenceKeypoint.new(1, esp_library.settings.health_bars.gradient[3])}})
        local health_bar_text = funcs:create("TextLabel", {Name = "healthtext", BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center; BorderSizePixel = 0, Visible = false, Parent = inside_healthbar, TextSize = 12, FontFace = text_font, TextStrokeTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255), AutomaticSize = Enum.AutomaticSize.X});

        local update_esp = function()
            local esp_connection;
            local hide_esp = function()
                box_main.Visible  = false;
                nametag.Visible = false;
                behind_healthbar.Visible = false;

                if not player then
                    player_folder:Destroy();
                    esp_connection:Disconnect();
                end;
            end;

            esp_connection = run_service.RenderStepped:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                    local hrp = player.Character.HumanoidRootPart;
                    local humanoid = player.Character.Humanoid;
                    local screen_position, visible = camera:WorldToViewportPoint(hrp.Position);
                    local box_size = funcs:get_box_size(obj.v2new(screen_position.X, screen_position.Y), hrp.CFrame * obj.cframenew(0,.25,0));
                    local box_position = funcs:vector_2_floor(obj.v2new(screen_position.X, screen_position.Y + 5) - box_size / 2);

                    if visible then

                        if esp_library.settings.master_switch then

                            do -- boxes
                                box_main.Visible = esp_library.settings.boxes.enabled;

                                box_gradient.Enabled = esp_library.settings.boxes.gradient[1] 
                                box_gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, esp_library.settings.boxes.gradient[2]), ColorSequenceKeypoint.new(1, esp_library.settings.boxes.gradient[3])}
                                

                                box_outline_gradient.Enabled = esp_library.settings.boxes.gradient[1] 
                                box_outline_gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, esp_library.settings.boxes.gradient[2]), ColorSequenceKeypoint.new(1, esp_library.settings.boxes.gradient[3])}

                                box_outline.Enabled = esp_library.settings.boxes.enabled;
                                box_outline.Color = esp_library.settings.boxes.color
        
                                box_main.Position = UDim2.new(0, box_position.X, 0, box_position.Y)
                                box_main.Size = UDim2.new(0, box_size.X, 0, box_size.Y);

                                if esp_library.settings.boxes.filled.enabled then
                                    box_main.BackgroundTransparency = esp_library.settings.boxes.filled.transparency;
                                    box_main.BackgroundColor3 = esp_library.settings.boxes.filled.color;
                                else
                                    box_main.BackgroundTransparency = 1
                                end

                                if esp_library.settings.boxes.animate then
                                    rotation_angle = rotation_angle + (tick() - _tick) * esp_library.settings.boxes.animatespeed * math.cos(math.pi / 4 * tick() - math.pi / 2)
                                    box_gradient.Rotation = rotation_angle;
                                    box_outline_gradient.Rotation = rotation_angle;
                                else
                                    box_gradient.Rotation = 90;
                                    box_outline_gradient.Rotation = 90;
                                end

                                _tick = tick();
                            end

                            do -- names
                                nametag.Visible = esp_library.settings.names.enabled;
                                nametag.TextColor3 = esp_library.settings.names.color;

                                if esp_library.settings.names.outline then
                                    nametag.TextStrokeTransparency = 0;
                                else
                                    nametag.TextStrokeTransparency = 1;
                                end

                                local lower = `{string.lower(player.DisplayName)}`
                                local higher = `{string.upper(player.DisplayName)}`

                                nametag.Text = esp_library.settings.names.type == "lower" and lower or higher;
                                nametag.Size = UDim2.new(0, box_size.X, 0, 0)
                                nametag.Position = UDim2.new(0, box_position.X, 0, box_position.Y - 10);
                                nametag.TextXAlignment = Enum.TextXAlignment[esp_library.settings.names.layout];

                                do -- flags
                                    do -- distance

                                        if esp_library.settings.flags.distance[1] then
                                            local distance = obj.floor((localplayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude);
                                            nametag.Text = esp_library.settings.names.type == "lower" and `{lower} (<font color="rgb(119, 120, 255)">{distance}</font>)` or `{higher} (<font color="rgb(255,0,0)>{distance}</font>)`
                                        else
                                            nametag.Text = esp_library.settings.names.type == "lower" and lower or higher;
                                        end

                                    end
                                end
                            end

                            do  -- healthbars
                                behind_healthbar.Visible = esp_library.settings.health_bars.enabled;
                                behind_healthbar.Size = UDim2.new(0, esp_library.settings.health_bars.thickness, 0, box_size.Y);
                                behind_healthbar.Position = UDim2.new(0, box_position.X - esp_library.settings.health_bars.offset, 0, box_position.Y);

                                inside_healthbar.BackgroundColor3 = esp_library.settings.health_bars.color;

                                health_bar_gradient.Enabled = esp_library.settings.health_bars.gradient[1];
                                health_bar_gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, esp_library.settings.health_bars.gradient[2]), ColorSequenceKeypoint.new(1, esp_library.settings.health_bars.gradient[3])}
                            
                                health_bar_text.Visible = esp_library.settings.health_bars.text;
                                health_bar_text.TextColor3 = esp_library.settings.health_bars.color;
                                health_bar_text.Size = UDim2.new(1,0,0,0);
                                health_bar_text.Position = UDim2.new(0,-25,0,0)

                                local calculate_health = function()
                                    local health = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1);
                                    health_bar_text.Text = tostring(obj.floor((humanoid.Health / humanoid.MaxHealth) * 100 + 0.5));
                                    game:GetService("TweenService"):Create(inside_healthbar, TweenInfo.new(esp_library.settings.health_bars.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(1,health)}):Play();
                                    if esp_library.settings.health_bars.use_health_color then
                                        inside_healthbar.BackgroundColor3 = Color3.fromHSV(health * 0.3, 1, 1);
                                        health_bar_gradient.Enabled = false;
                                    else
                                        health_bar_gradient.Enabled = esp_library.settings.health_bars.gradient[1];
                                    end
                                end

                                humanoid:GetPropertyChangedSignal("Health"):Connect(calculate_health);
                                humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(calculate_health);
                                calculate_health();
                            end

                        else
                            hide_esp();
                        end

                    else
                        hide_esp()
                    end

                end;
                
            end);
        end;
        coroutine.wrap(update_esp)()
    end;
    do
        for _, v in game:GetService("Players"):GetPlayers() do
            if v ~= localplayer then
                coroutine.wrap(create_esp)(v)
            end
        end

        game:GetService("Players").PlayerAdded:Connect(function(a)
            coroutine.wrap(create_esp)(a)
        end)

        game:GetService("Players").PlayerRemoving:Connect(function(player)
            coroutine.wrap(remove_esp)(player)
        end)
    end
end

function esp_library:get_library()
    return esp_library.settings;
end

return esp_library;
