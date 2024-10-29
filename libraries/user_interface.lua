if getgenv().library then
    getgenv().library:unload();
end
local library = {
    theme = {
        accent = Color3.fromRGB(160, 255, 215);
    };
    ui_key = Enum.KeyCode.End;
    tween_speed = 0.2;

    tabs = {};
    realtabs = {};
    subtabs = {};
    realsubtabs = {};
    sections = {};

    connections = {};
    flags = {};

    unnamed_flags = 0;
    holder = nil;
    mainframe = nil;
    dragging = nil;
    open = true;
    Keys = {
        [Enum.KeyCode.LeftShift] = "LS",
        [Enum.KeyCode.RightShift] = "RS",
        [Enum.KeyCode.LeftControl] = "LC",
        [Enum.KeyCode.RightControl] = "RC",
        [Enum.KeyCode.LeftAlt] = "LA",
        [Enum.KeyCode.RightAlt] = "RA",
        [Enum.KeyCode.CapsLock] = "CAPS",
        [Enum.KeyCode.One] = "1",
        [Enum.KeyCode.Two] = "2",
        [Enum.KeyCode.Three] = "3",
        [Enum.KeyCode.Four] = "4",
        [Enum.KeyCode.Five] = "5",
        [Enum.KeyCode.Six] = "6",
        [Enum.KeyCode.Seven] = "7",
        [Enum.KeyCode.Eight] = "8",
        [Enum.KeyCode.Nine] = "9",
        [Enum.KeyCode.Zero] = "0",
        [Enum.KeyCode.KeypadOne] = "Num1",
        [Enum.KeyCode.KeypadTwo] = "Num2",
        [Enum.KeyCode.KeypadThree] = "Num3",
        [Enum.KeyCode.KeypadFour] = "Num4",
        [Enum.KeyCode.KeypadFive] = "Num5",
        [Enum.KeyCode.KeypadSix] = "Num6",
        [Enum.KeyCode.KeypadSeven] = "Num7",
        [Enum.KeyCode.KeypadEight] = "Num8",
        [Enum.KeyCode.KeypadNine] = "Num9",
        [Enum.KeyCode.KeypadZero] = "Num0",
        [Enum.KeyCode.Minus] = "-",
        [Enum.KeyCode.Equals] = "=",
        [Enum.KeyCode.Tilde] = "~",
        [Enum.KeyCode.LeftBracket] = "[",
        [Enum.KeyCode.RightBracket] = "]",
        [Enum.KeyCode.RightParenthesis] = ")",
        [Enum.KeyCode.LeftParenthesis] = "(",
        [Enum.KeyCode.Semicolon] = ",",
        [Enum.KeyCode.Quote] = "'",
        [Enum.KeyCode.BackSlash] = "\\",
        [Enum.KeyCode.Comma] = ",",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Slash] = "/",
        [Enum.KeyCode.Asterisk] = "*",
        [Enum.KeyCode.Plus] = "+",
        [Enum.KeyCode.Period] = ".",
        [Enum.KeyCode.Backquote] = "`",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3"
    };
};

do
    library.__index = library
    library.tabs.__index = library.tabs
    library.subtabs.__index = library.subtabs
    library.sections.__index = library.sections

    local tween_service = game:GetService("TweenService");
    local user_input_service = game:GetService("UserInputService");

    do
        local http_service = game:GetService("HttpService");

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
                writefile(Name .. ".font", http_service:JSONEncode(Data));
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

    local instance = {instances = {}}
    function instance.new(class, properties)
        local inst = Instance.new(class)
        for property, value in next, properties do
            inst[property] = value
        end
        
        table.insert(instance.instances, inst)
        return inst
    end

    local screen_gui = instance.new("ScreenGui", {
        ResetOnSpawn = false;
        Parent = gethui();
        ZIndexBehavior = Enum.ZIndexBehavior.Global;
    });

    library.holder = screen_gui;

    function library:round(number, float)
        return float * math.round(number / float)
    end;

    function library:next_flag()
        library.unnamed_flags += 1;
        return string.format("%.27g", library.unnamed_flags);
    end

    function library:setopen(bool)
        library.open = bool;
        library.mainframe.Visible = bool;
    end;

    function library:connect(signal, callback)
        local con = signal:Connect(callback);
        table.insert(library.connections, con);
        return con;
    end;

    function library:disconnect(signal)
        signal:Disconnect();
        table.remove(library.connections, table.find(library.connections, signal));
    end

    function library:unload()
        for _, con in library.connections do
            con:Disconnect();
        end

        if library.holder then
            library.holder:Destroy()
        end

        getgenv().library = nil
    end

    function library:is_mouse_over_frame(Frame)
        local Mouse = game.Players.LocalPlayer:GetMouse();
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
            and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then
    
            return true;
        end;
    end

    do 
        local mouselib = { -- mouse lib made by  samet.exe
            objects = {
                v2new = Vector2.new; 
                draw = Drawing.new;
            }
        };

        local user_input_service = game:GetService("UserInputService");
        local runservice = game:GetService("RunService");

        function mouselib:draw(class,properties)
            local drawing = mouselib.objects.draw(class);

            for property, value in properties do
                drawing[property] = value;
            end

            return drawing
        end

        function mouselib:create(props)
            user_input_service.MouseIconEnabled = false
            local mouse = {
                color = props.Color or Color3.fromRGB(255,255,255);
                outline = props.OutlineColor or Color3.fromRGB(0,0,0);
            }

            local triangleoutline = mouselib:draw("Triangle", {
                Thickness = 1;
                Filled = false;
                Color = mouse.outline;
                Visible = true;
            });

            local triangleinline = mouselib:draw("Triangle", {
                Thickness = 1;
                Filled = true;
                Color = mouse.color;
                Visible = true;
            })

            do
                runservice.PostSimulation:Connect(function()
                    local position = user_input_service:GetMouseLocation();

                    triangleinline.PointA = mouselib.objects.v2new(position.X, position.Y);
                    triangleinline.PointB = mouselib.objects.v2new(position.X + 16, position.Y + 4);
                    triangleinline.PointC = mouselib.objects.v2new(position.X + 4, position.Y + 16);

                    triangleoutline.PointA = triangleinline.PointA
                    triangleoutline.PointB = triangleinline.PointB
                    triangleoutline.PointC = triangleinline.PointC
                end);
            end;

            function mouselib:setvisiblity(v)
                triangleoutline.Visible = v;
                triangleinline.Visible = v;
            end

            return mouselib
        end

        local mouse = mouselib:create({Color = library.theme.accent, OutlineColor = Color3.fromRGB(0,0,0)})
        mouse:setvisiblity(true)
        user_input_service.MouseIconEnabled = false
    end

    do
        function library:window(properties)
            local window = {name = properties.name or 'window', objects = {}};

            local mainframe = instance.new("Frame", {
                Name = "mainframe";
                Parent = library.holder;
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 2;
                Position = UDim2.new(0.5, 0, 0.5, 0);
                Size = UDim2.new(0, 650, 0, 450);
            })

            library.mainframe = mainframe;
            
            local text = instance.new("TextLabel", {
                Name = "text";
                Parent = mainframe;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 5, 0, 2);
                Size = UDim2.new(1, 0, 0, 20);
                FontFace = text_font;
                Text = window.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                RichText = true;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })
            
            local shadow = instance.new("ImageLabel", {
                Name = "shadow";
                Parent = mainframe;
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0.5, 0, 0.5, 0);
                Size = UDim2.new(1, 90, 1, 85);
                ZIndex = -5;
                Image = "rbxassetid://112971167999062";
                ImageColor3 = Color3.fromRGB(0, 0, 0);
                ImageTransparency = 0.230;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(112, 112, 147, 147);
                SliceScale = 0.600;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(148, 148, 148)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))};
                Parent = mainframe;
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(45, 45, 45);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = mainframe;
            })

            do
                do
                    local user_input_service = game:GetService("UserInputService");

                    local gui = mainframe
                    local dragInput, dragStart, startPos
                
                    local function update(input)
                        local delta = input.Position - dragStart
                        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                
                    library:connect(gui.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            library.dragging = true
                            dragStart = input.Position
                            startPos = gui.Position
                            input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    library.dragging = false
                                end
                            end)
                        end
                    end)
                
                    library:connect(gui.InputChanged, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            dragInput = input
                        end
                    end)
                
                    library:connect(user_input_service.InputChanged, function(input)
                        if input == dragInput and library.dragging then
                            update(input)
                        end
                    end)
                end

                do
                    local user_input_service = game:GetService("UserInputService");

                    library:connect(user_input_service.InputBegan, function(inp,gpe)
                        if gpe then return end;

                        if inp.KeyCode == library.ui_key then
                            library:setopen(not library.open);
                        end;
                    end);
                end
            end

            local inline = instance.new("Frame", {
                Name = "inline";
                Parent = mainframe;
                BackgroundColor3 = Color3.fromRGB(18, 18, 18);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 201, 0, 26);
                Size = UDim2.new(1, -202, 1, -27);
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(45, 45, 45);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = inline;
            })
            
            local content = instance.new("Frame", {
                Name = "content";
                Parent = inline;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(255, 255, 255);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 5, 0, 5);
                Size = UDim2.new(1, -10, 1, -10);
            })
            
            local tabholder = instance.new("Frame", {
                Name = "tabholder";
                Parent = mainframe;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 5, 0, 26);
                Size = UDim2.new(1, -455, 1, -30);
            })

            local UIListLayout = instance.new("UIListLayout", {
                Parent = tabholder;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Padding = UDim.new(0, 8);
            })

            local subtabholder = instance.new("Frame", {
                Name = "subtabholder";
                Parent = mainframe;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 201, 0, 3);
                Size = UDim2.new(1, -202, 0, 20);
            })

            do
                window.objects = {
                    content = content;
                    tabs = tabholder;
                    subtabs = subtabholder;
                };
            end

            return setmetatable(window, library);
        end

        function library:tab(options)
            local tab = {
                window = self;
                name = options.name or 'tab';
                active = false;
                hovered = false;
            };

            local inactive = instance.new("TextButton", {
                Name = "inactive";
                Parent = tab.window.objects.tabs;
                BackgroundColor3 = Color3.fromRGB(29, 29, 29);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(0, 190, 0, 25);
                AutoButtonColor = false;
                Font = Enum.Font.SourceSans;
                Text = "";
                TextColor3 = Color3.fromRGB(0, 0, 0);
                TextSize = 14.000;
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(45, 45, 45);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = inactive;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(159, 159, 159))};
                Parent = inactive;
            })
            
            local glow = instance.new("Frame", {
                Name = "glow";
                Parent = inactive;
                BackgroundColor3 = Color3.fromRGB(61, 61, 61);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(0, 11, 1, 0);
            })
            
            local UIGradient = instance.new("UIGradient", {
                Rotation = 90;
                Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.01, 0.93), NumberSequenceKeypoint.new(0.16, 0.95), NumberSequenceKeypoint.new(0.27, 0.96), NumberSequenceKeypoint.new(0.60, 0.94), NumberSequenceKeypoint.new(1.00, 1.00)};
                Parent = glow;
            })
            
            local hide = instance.new("Frame", {
                Name = "hide";
                Parent = inactive;
                BackgroundColor3 = Color3.fromRGB(18, 18, 18);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 5, 1, 0);
                Visible = false;
            })
            
            local liner = instance.new("Frame", {
                Name = "liner";
                Parent = inactive;
                BackgroundColor3 = Color3.fromRGB(61, 61, 61);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(0, 1, 1, 0);
            })
            
            local text = instance.new("TextLabel", {
                Name = "text";
                Parent = inactive;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 7, 0, 0);
                Size = UDim2.new(1, 0, 1, 0);
                FontFace = text_font;
                Text = tab.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })

            local current_tabs_sub_tab_content =  instance.new("Frame", {
                Name = tab.name;
                Parent = tab.window.objects.subtabs;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                Visible = false;
            })

            local UIListLayout = instance.new("UIListLayout", {
                Parent = current_tabs_sub_tab_content;
                FillDirection = Enum.FillDirection.Horizontal;
                SortOrder = Enum.SortOrder.LayoutOrder;
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDim.new(0, 4);
            })

            local tab_content = instance.new("Frame", {
                Name = tab.name;
                Parent = tab.window.objects.content;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                Visible = false;
            })

            function tab:switch(bool)
                tab.active = bool;
                current_tabs_sub_tab_content.Visible = bool;
                tab_content.Visible = bool;

                if bool then
                    tween_service:Create(inactive, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 194, 0, 25)}):Play();
                    tween_service:Create(liner, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = library.theme.accent}):Play();
                    tween_service:Create(glow, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play();
                    hide.Visible = true;
                    current_tabs_sub_tab_content.Visible = true;
                    tab_content.Visible = true;
                else
                    tween_service:Create(inactive, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 190, 0, 25)}):Play();
                    tween_service:Create(liner, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(61,61,61)}):Play();
                    tween_service:Create(glow, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play();
                    hide.Visible = false;
                    current_tabs_sub_tab_content.Visible = false;
                    tab_content.Visible = false;
                end
            end

            do
                library:connect(inactive.MouseButton1Down, function()
                    for i,v in library.realtabs do
                        v:switch(v == tab);
                    end
                end)
            end

            function tab:sub_tab(options)
                local sub_tab = {name = options.name or 'sub_tab', active = false; hovered = false; objects = {};};

                local sub_tab_inactive = instance.new("TextButton", {
                    Name = "inactive";
                    Parent = current_tabs_sub_tab_content;
                    BackgroundColor3 = Color3.fromRGB(29, 29, 29);
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 1, 0);
                    AutoButtonColor = false;
                    FontFace = text_font;
                    Text = sub_tab.name;
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    TextSize = 12.000;
                    TextStrokeTransparency = 0.000;
                })

                local subUIStroke = instance.new("UIStroke", {
                    Color = Color3.fromRGB(45, 45, 45);
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                    Parent = sub_tab_inactive;
                })
                
                local subliner = instance.new("Frame", {
                    Name = "liner";
                    Parent = sub_tab_inactive;
                    BackgroundColor3 = Color3.fromRGB(61, 61, 61);
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 1, 0, 0);
                    Size = UDim2.new(1, -2, 0, 1);
                })
                
                local subhide = instance.new("Frame", {
                    Name = "hide";
                    Parent = sub_tab_inactive;
                    BackgroundColor3 = Color3.fromRGB(18, 18, 18);
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 1, 0);
                    Size = UDim2.new(1, 0, 0, 5);
                    Visible = false;
                })
                
                local subUIGradient = instance.new("UIGradient", {
                    Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(159, 159, 159))};
                    Rotation = 90;
                    Parent = sub_tab_inactive;
                })
                
                local subglow = instance.new("Frame", {
                    Name = "glow";
                    Parent = sub_tab_inactive;
                    BackgroundColor3 = Color3.fromRGB(61, 61, 61);
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 0, 11);
                })
                
                local subtabcpntent  = instance.new("Frame", {
                    Name = "subtab";
                    Parent = tab_content;
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BackgroundTransparency = 1.000;
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 1, 0);
                    Visible = false;
                })

                local subbUIGradient = instance.new("UIGradient", {
                    Rotation = 90;
                    Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.01, 0.93), NumberSequenceKeypoint.new(0.16, 0.95), NumberSequenceKeypoint.new(0.27, 0.96), NumberSequenceKeypoint.new(0.60, 0.94), NumberSequenceKeypoint.new(1.00, 1.00)};
                    Parent = subglow;
                })

                local sectionholders = instance.new("ScrollingFrame", {
                    Name = "sectionholders";
                    Parent = subtabcpntent;
                    Active = true;
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BackgroundTransparency = 1.000;
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 1, 0);
                    ScrollBarThickness = 0;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                })
                
                local left = instance.new("Frame", {
                    Name = "left";
                    Parent = sectionholders;
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BackgroundTransparency = 1.000;
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 5, 0, 5);
                    Size = UDim2.new(0.479999989, -5, 1, -5);
                })
                
                local UIListLayout = instance.new("UIListLayout", {
                    Parent = left;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Padding = UDim.new(0, 8);
                })
                
                local right = instance.new("Frame", {
                    Name = "right";
                    Parent = sectionholders;
                    AnchorPoint = Vector2.new(1, 0);
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BackgroundTransparency = 1.000;
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Position = UDim2.new(1, -5, 0, 5);
                    Size = UDim2.new(0.479999989, -5, 1, -5);
                })

                local UIListLayout = instance.new("UIListLayout", {
                    Parent = right;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Padding = UDim.new(0, 8);
                })

                function sub_tab:switch(bool)
                    sub_tab.active = bool;
                    subtabcpntent.Visible = bool;
        
                    if bool then
                        tween_service:Create(sub_tab_inactive, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad,Enum.EasingDirection.InOut), {Size = UDim2.new(1,0,1,2)}):Play();
                        tween_service:Create(subliner, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = library.theme.accent}):Play();
                        tween_service:Create(subglow, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = library.theme.accent}):Play();
                        subhide.Visible = true;
                        subtabcpntent.Visible = true;
                    else
                        tween_service:Create(sub_tab_inactive, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad,Enum.EasingDirection.InOut), {Size = UDim2.new(1,0,1,0)}):Play();
                        tween_service:Create(subliner, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(61,61,61)}):Play();
                        tween_service:Create(subglow, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromRGB(61,61,61)}):Play();
                        subhide.Visible = false;
                        subtabcpntent.Visible = false;
                    end
                end

                do
                    library:connect(sub_tab_inactive.MouseButton1Down, function()
                        for i,v in library.realsubtabs do
                            v:switch(v == sub_tab);
                        end;
                    end);
                end;

                do
                    sub_tab.objects = {
                        content = subtabcpntent;
                        main = sectionholders;
                        right = right;
                        left = left;
                    };
                end;

                table.insert(library.realsubtabs, sub_tab);
                return setmetatable(sub_tab, library.subtabs);
            end;

            table.insert(library.realtabs, tab);
            return setmetatable(tab, library.tabs);
        end;

        function library.subtabs:section(properties)
            local section = {
                sub_tab = self;
                name = properties.name or 'section',
                side = properties.side or 'left',
                objects = {};
            };

            local newsection = instance.new("Frame", {
                Name = "section";
                Parent = section.side:lower() == "left" and section.sub_tab.objects.left or section.side:lower() == "right" and section.sub_tab.objects.right;
                BackgroundColor3 = Color3.fromRGB(29, 29, 29);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 45);
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local topbar = instance.new("Frame", {
                Name = "topbar";
                Parent = newsection;
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 20);
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(45, 45, 45);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = newsection;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(72, 72, 72))};
                Parent = topbar;
            })
            
            local liner = instance.new("Frame", {
                Name = "liner";
                Parent = topbar;
                AnchorPoint = Vector2.new(0, 1);
                BackgroundColor3 = Color3.fromRGB(45, 45, 45);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 1, 0);
                Size = UDim2.new(1, 0, 0, 1);
            })
            
            local text = instance.new("TextLabel", {
                Name = "text";
                Parent = topbar;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 5, 0, 0);
                Size = UDim2.new(1, 0, 1, 0);
                FontFace = text_font;
                Text = section.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(161, 161, 161))};
                Rotation = 90;
                Parent = newsection;
            })
            
            local content = instance.new("Frame", {
                Name = "content";
                Parent = newsection;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 7, 0, 26);
                Size = UDim2.new(1, -14, 1, -21);
            })
            
            local UIListLayout = instance.new("UIListLayout", {
                Parent = content;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Padding = UDim.new(0, 6);
            })
            
            do
                section.objects = {
                    main = content;
                };
            end

            return setmetatable(section, library.sections);
        end

        function library.sections:toggle(options)
            local toggle = {
                section = self;
                name = options.name or 'toggle',
                state = options.state or false;
                flag = options.flag or library:next_flag();
                callback = options.callback or function() end;
                toggled = false;
            };

            local newtoggle = instance.new("TextButton", {
                Name = "toggle";
                Parent = toggle.section.objects.main;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 12);
                Font = Enum.Font.SourceSans;
                Text = "";
                TextColor3 = Color3.fromRGB(0, 0, 0);
                TextSize = 14.000;
            })
            
            local indicator = instance.new("Frame", {
                Name = "indicator";
                Parent = newtoggle;
                AnchorPoint = Vector2.new(0, 0.5);
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 0.5, 0);
                Size = UDim2.new(0, 9, 0, 9);
            })
            
            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = indicator;
            })

            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 150))};
                Parent = indicator;
            })

            local text = instance.new("TextLabel", {
                Name = "text";
                Parent = newtoggle;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 15, 0, 0);
                Size = UDim2.new(1, -15, 1, 0);
                FontFace = text_font;
                Text = toggle.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })

            local set_state = function()
                toggle.toggled = not toggle.toggled;
                tween_service:Create(indicator, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = toggle.toggled and library.theme.accent or Color3.fromRGB(34,34,34)}):Play();
                library.flags[toggle.flag] = toggle.toggled;
                toggle.callback(toggle.toggled); 
            end

            library:connect(newtoggle.MouseButton1Down, set_state);

            local set_defaults = function(bool)
                if bool ~= toggle.state then
                    set_state();
                end
            end

            function toggle:settings(size)
                local settingsw = {objects = {}};

                local settingswindow = instance.new("Frame", {
                    Name = "settings window";
                    Parent = newtoggle;
                    BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Position = UDim2.new(0, 0, 0, 18);
                    Size = UDim2.new(1, 16, 0, size);
                    ZIndex = 1;
                    Visible = false;
                })
                
                local UIGradient = instance.new("UIGradient", {
                    Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(148, 148, 148)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))};
                    Parent = settingswindow;
                })
                
                local shadow = instance.new("ImageLabel", {
                    Name = "shadow";
                    Parent = settingswindow;
                    AnchorPoint = Vector2.new(0.5, 0.5);
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BackgroundTransparency = 1.000;
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Position = UDim2.new(0.5, 0, 0.5, 0);
                    Size = UDim2.new(1, 90, 1, 85);
                    ZIndex = -5;
                    Image = "rbxassetid://112971167999062";
                    ImageColor3 = Color3.fromRGB(0, 0, 0);
                    ImageTransparency = 0.230;
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(112, 112, 147, 147);
                    SliceScale = 0.600;
                })
                
                local content = instance.new("Frame", {
                    Name = "content";
                    Parent = settingswindow;
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BackgroundTransparency = 1.000;
                    BorderColor3 = Color3.fromRGB(0, 0, 0);
                    BorderSizePixel = 0;
                    Position = UDim2.new(0,7,0,5);
                    Size = UDim2.new(1, -12, 1, -5);
                })
                
                local UIListLayout = instance.new("UIListLayout", {
                    Parent = content;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Padding = UDim.new(0,6)
                })

                local UIStroke = instance.new("UIStroke", {
                    Color = Color3.fromRGB(45,45, 45);
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                    Parent = settingswindow;
                })

                do
                    settingsw.objects = {
                        main = content;
                    };
                end


                local set_open = function()
                    settingswindow.Visible = not settingswindow.Visible

                    if settingswindow.Visible then
                        for i,v in newtoggle:GetDescendants() do
                            if not string.find(v.ClassName, "UI") and v.Name ~= "shadow" then
                                v.ZIndex = 5
                            end
                        end
                    else
                        for i,v in newtoggle:GetDescendants() do
                            if not string.find(v.ClassName, "UI") and v.Name ~= "shadow" then
                                v.ZIndex = 1
                            end
                        end
                    end
                end

                library:connect(newtoggle.MouseButton2Down, set_open);

                return setmetatable(settingsw, library.sections);
            end

            set_defaults(toggle.state);
            return toggle;
        end;

        function library.sections:button(options)
            local button = {
                section = self;
                name = options.name or 'button';
                callback = options.callback or function() end;
            };

            local newbutton = instance.new("TextButton", {
                Name = "button";
                Parent = button.section.objects.main;
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 15);
                AutoButtonColor = false;
                FontFace =text_font;
                Text = button.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = newbutton;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 150))};
                Parent = newbutton;
            })

            local handle_click = function()
                button.callback();
                tween_service:Create(UIStroke, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = library.theme.accent}):Play();
                task.wait(0.1)
                tween_service:Create(UIStroke, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(0,0,0)}):Play();
            end

            library:connect(newbutton.MouseButton1Down, handle_click)

            return button
        end;

        function library.sections:slider(options)
            local slider  = {
                section = self,
                name = options.name or 'slider';
                min = options.min or 1,
                max = options.max or 100,
                state = options.state or 50,
                decimals = options.decimals or 1,
                flag = options.flag or library:next_flag();
                callback = options.callback or function()end;
                suffix = options.suffix or "";
            };

            local newslider = instance.new("Frame", {
                Name = "slider";
                Parent = slider.section.objects.main;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 24);
            })
            
            local realslider = instance.new("Frame", {
                Name = "realslider";
                Parent = newslider;
                AnchorPoint = Vector2.new(0, 1);
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 1, 0);
                Size = UDim2.new(1, 0, 0, 9);
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = realslider;
            })

            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 150))};
                Parent = realslider;
            })
            
            local indicator = instance.new("Frame", {
                Name = "indicator";
                Parent = realslider;
                BackgroundColor3 = library.theme.accent;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(0.5, 0, 1, 0);
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 150))};
                Parent = indicator;
            })

            local text = instance.new("TextLabel", {
                Name = "text";
                Parent = newslider;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 13);
                FontFace = text_font;
                Text = slider.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })
            
            local valuetext = instance.new("TextLabel", {
                Name = "value";
                Parent = newslider;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 13);
                FontFace = text_font;
                Text = "50st";
                TextColor3 = Color3.fromRGB(175, 175, 175);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Right;
            })

            local _sliding = false
            local _val = slider.state
            local _text_value = ("[value]" .. slider.suffix)

            local _set = function(value)
                value = math.clamp(library:round(value, slider.decimals), slider.min, slider.max)

                local _sizeX = ((value - slider.min) / (slider.max - slider.min))
                indicator.Size = UDim2.new(_sizeX,0,1,0)
                valuetext.Text = _text_value:gsub("%[value%]", string.format("%.14g", value));

                library.flags[slider.flag] = value;
                slider.callback(value);
            end

            local i_slide = function(input)
                local sizeX = (input.Position.X - realslider.AbsolutePosition.X) / realslider.AbsoluteSize.X
                local value = ((slider.max - slider.min) * sizeX) + slider.min
                library.dragging = nil;
                _set(value)
            end

            library:connect(indicator.InputBegan, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    _sliding = true;
                    i_slide(inp)
                end
            end)

            library:connect(indicator.InputEnded, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    _sliding = false;
                end
            end)

            library:connect(realslider.InputBegan, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    _sliding = true;
                    i_slide(inp)
                end
            end)

            library:connect(realslider.InputEnded, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    _sliding = false;
                end
            end)

            do
                local user_input_service = game:GetService("UserInputService");

                library:connect(user_input_service.InputChanged, function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement and _sliding then
                        i_slide(inp);
                    end
                end)
            end
            _set(slider.state)
            return slider
        end

        function library.sections:dropdown(options)
            local dropdown = {
                section = self;
                name = options.name or 'dropdown',
                options = options.options or {"one","two","three"};
                state = options.state or nil;
                flag = options.flag or library:next_flag();
                callback = options.callback or function () end;
                multi = options.multi or false;
            };

            local option_instances = {};
            local option_count = 0;
            local chosen = dropdown.multi and {} or nil;

            local newdropdown = instance.new("Frame", {
                Name = "dropdown";
                Parent = dropdown.section.objects.main;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 33);
            })
            
            local text = instance.new("TextLabel", {
                Name = "text";
                Parent = newdropdown;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 13);
                FontFace = text_font;
                Text = dropdown.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })

            local realdropdown = instance.new("TextButton", {
                Name = "realdropdown";
                Parent = newdropdown;
                AnchorPoint = Vector2.new(0, 1);
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 1, 0);
                Size = UDim2.new(1, 0, 0, 17);
                AutoButtonColor = false;
                Font = Enum.Font.SourceSans;
                Text = "";
                TextColor3 = Color3.fromRGB(0, 0, 0);
                TextSize = 14.000;
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = realdropdown;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 150))};
                Parent = realdropdown;
            })
            
            local valuetext = instance.new("TextLabel", {
                Name = "value";
                Parent = realdropdown;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 5, 0, 0);
                Size = UDim2.new(1, -10, 1, 0);
                FontFace = text_font;
                Text = "option";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextTruncate = Enum.TextTruncate.AtEnd
            })
            
            local plus = instance.new("TextLabel", {
                Name = "plus";
                Parent = realdropdown;
                AnchorPoint = Vector2.new(1, 0);
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 15, 1, 0);
                FontFace = text_font;
                Text = "+";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
            })
            
            local optionholder = instance.new("Frame", {
                Name = "optionholder";
                Parent = newdropdown;
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 1, 4);
                Size = UDim2.new(1, 0, 0, 15);
                AutomaticSize = Enum.AutomaticSize.Y,
                Visible = false
            })
            
            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = optionholder;
            })

            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(148, 148, 148)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))};
                Parent = optionholder;
            })
            
            local UIListLayout = instance.new("UIListLayout", {
                Parent = optionholder;
                SortOrder = Enum.SortOrder.LayoutOrder;
            })

            local set_open = function()
                optionholder.Visible = not optionholder.Visible

                if optionholder.Visible then
                    for i,v in optionholder:GetDescendants() do
                        if not string.find(v.Name, "UI") then
                            v.ZIndex = 15;
                        end 
                        optionholder.ZIndex = 15;
                    end
                    plus.Text = "-"
                else
                    for i,v in optionholder:GetDescendants() do
                        if not string.find(v.Name, "UI") then
                            v.ZIndex = 1;
                        end
                        optionholder.ZIndex = 1;
                    end
                    plus.Text = "+"
                end
            end

            library:connect(realdropdown.MouseButton1Down, set_open)

            local _handle_option_clicked = function(option, button, text)
                library:connect(button.MouseButton1Down, function()
                    if dropdown.multi then
                        local index = table.find(chosen, option)

                        if index then
                            table.remove(chosen, index)
                        else
                            table.insert(chosen, option)
                        end

                        valuetext.Text = table.concat(chosen, ", ")
                        tween_service:Create(text, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = index and Color3.fromRGB(255,255,255) or library.theme.accent}):Play()
                        library.flags[dropdown.flag] = chosen;
                        dropdown.callback(chosen);
                    else
                        for i,v in option_instances do
                            if i ~= option then
                                tween_service:Create(v.text, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
                            end
                        end

                        chosen = option 
                        valuetext.Text = option
                        tween_service:Create(text, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = library.theme.accent}):Play()
                        library.flags[dropdown.flag] = option;
                        dropdown.callback(option);
                    end
                end)
            end

            local _create_options = function(table)
                for i, option in table do
                    option_instances[option] = {};

                    local optionbuttom = instance.new("TextButton", {
                        Name = "option";
                        Parent = optionholder;
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                        BackgroundTransparency = 1.000;
                        BorderColor3 = Color3.fromRGB(0, 0, 0);
                        BorderSizePixel = 0;
                        Size = UDim2.new(1, 0, 0, 15);
                        AutoButtonColor = false;
                        Font = Enum.Font.SourceSans;
                        Text = "";
                        TextColor3 = Color3.fromRGB(0, 0, 0);
                        TextSize = 14.000;
                    })
                    
                    local text = instance.new("TextLabel", {
                        Name = "text";
                        Parent = optionbuttom;
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                        BackgroundTransparency = 1.000;
                        BorderColor3 = Color3.fromRGB(0, 0, 0);
                        BorderSizePixel = 0;
                        Position = UDim2.new(0, 5, 0, 0);
                        Size = UDim2.new(1, -5, 1, 0);
                        FontFace = text_font;
                        Text = option;
                        TextColor3 = Color3.fromRGB(255, 255, 255);
                        TextSize = 12.000;
                        TextStrokeTransparency = 0.000;
                        TextXAlignment = Enum.TextXAlignment.Left;
                    })

                    option_instances[option].text = text;
                    option_instances[option].button = optionbuttom

                    option_count += 1 

                    _handle_option_clicked(option, optionbuttom, text)
                end
            end

            local _set = function(option)
                table.clear(chosen);

                option = type(option) == "table" and option or {};

                for i,v in option_instances do
                    if not table.find(option, i) then
                        tween_service:Create(v.text, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
                    end
                end

                for i,v in option do
                    if table.find(dropdown.options, i) and dropdown.multi then
                        tween_service:Create(v.text, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = library.theme.accent}):Play()
                    end
                end

                local text_chosen = {};
                for _, v in chosen do
                    table.insert(text_chosen, v)
                end

                valuetext.Text = table.concat(text_chosen, ", ")
                library.flags[dropdown.flag] = chosen 
                dropdown.callback(chosen)
            end

            dropdown.set = function(option)
                if dropdown.multi then
                    _set(option);
                else
                    for i,v in option_instances do
                        if i ~= option then
                            tween_service:Create(v.text, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
                        end
                    end

                    if table.find(dropdown.options, option) then
                        tween_service:Create(option_instances[option].text, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextColor3 = library.theme.accent}):Play()
                        valuetext.Text = option;
                        chosen = option;
                        library.flags[dropdown.flag] = option;
                        dropdown.callback(option)
                    else
                        valuetext.Text = "none";
                        chosen = nil;
                        library.flags[dropdown.flag] = chosen;
                        dropdown.callback(chosen)
                    end
                end
            end

            _create_options(dropdown.options)
            dropdown.set(dropdown.state)
            return dropdown
        end

        function library.sections:colorpicker(options)
            local colorpicker = {
                section = self;
                name = options.name or 'colorpicker',
                state = options.state or Color3.fromRGB(255,0,0),
                alpha = options.alpha or 1,
                flag = options.flag or library:next_flag();
                callback = options.callback or  function() end
            };

            local newcolorpicker = instance.new("Frame", {
                Name = "newcolorpicker";
                Parent = colorpicker.section.objects.main;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 15);
            })
            
            local colortext = instance.new("TextLabel", {
                Name = "colortext";
                Parent = newcolorpicker;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                FontFace = text_font;
                Text = colorpicker.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })
            
            local colorbutton = instance.new("TextButton", {
                Name = "colorbutton";
                Parent = newcolorpicker;
                AnchorPoint = Vector2.new(1, 0);
                BackgroundColor3 = Color3.fromRGB(255, 0, 0);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 15, 0, 15);
                AutoButtonColor = false;
                Font = Enum.Font.SourceSans;
                Text = "";
                TextColor3 = Color3.fromRGB(0, 0, 0);
                TextSize = 14.000;
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = colorbutton;
            })
            
            local UICorner = instance.new("UICorner", {
                Parent = colorbutton;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 150))};
                Parent = colorbutton;
            })

            local window = instance.new("Frame", {
                Name = "window";
                Parent = newcolorpicker;
                AnchorPoint = Vector2.new(1, 0);
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(1, 0, 0, 18);
                Size = UDim2.new(0, 150, 0, 120);
                Visible = false;
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(45, 45, 45);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = window;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(148, 148, 148)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))};
                Parent = window;
            })
            
            local windowcolor = instance.new("TextButton", {
                Name = "windowcolor";
                Parent = window;
                BackgroundColor3 = Color3.fromRGB(255, 0, 0);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 7, 0, 7);
                Size = UDim2.new(0, 115, 0, 105);
                AutoButtonColor = false;
                Font = Enum.Font.SourceSans;
                Text = "";
                TextColor3 = Color3.fromRGB(0, 0, 0);
                TextSize = 14.000;
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = windowcolor;
            })
            
            local windowsat = instance.new("ImageLabel", {
                Name = "windowsat";
                Parent = windowcolor;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                Image = "http://www.roblox.com/asset/?id=14684562507";
            })
            
            local windowval = instance.new("ImageLabel", {
                Name = "windowval";
                Parent = windowcolor;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                Image = "http://www.roblox.com/asset/?id=14684563800";
            })
            
            local windowdragger = instance.new("Frame", {
                Name = "windowdragger";
                Parent = windowcolor;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(0, 2, 0, 2);
            })
            
            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = windowdragger;
            })

            local windowhue = instance.new("ImageButton", {
                Name = "windowhue";
                Parent = window;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(1, -23, 0, 7);
                Size = UDim2.new(0, 17, 0, 104);
                Image = "http://www.roblox.com/asset/?id=14684557999";
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = windowhue;
            })
            
            local huedragger = instance.new("Frame", {
                Name = "huedragger";
                Parent = windowhue;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 1);
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = huedragger;
            })

            local set_open = function()
                window.Visible = not window.Visible;

                if window.Visible then
                    for i,v in window:GetDescendants() do
                        if not v.Name:find("UI") then
                            v.ZIndex = 15;
                        end
                    end
                    window.ZIndex = 15;
                else
                    for i,v in window:GetDescendants() do
                        if not v.Name:find("UI") then
                            v.ZIndex = 1;
                        end
                    end
                    window.ZIndex = 1;
                end
            end

            local sliding_palette = false;
            local sliding_hue = false;

            local saturation, hue, value = colorpicker.state:ToHSV();
            local hsv = colorpicker.state:ToHSV();
            local alpha = colorpicker.alpha;

            local set_state = function()
                local mouse_pos = user_input_service:GetMouseLocation();
                local real_pos = Vector2.new(mouse_pos.X, mouse_pos.Y - 57);

                local relative_palette = (real_pos - windowcolor.AbsolutePosition);
                local relative_hue = (real_pos - windowhue.AbsolutePosition);

                if sliding_palette then
                    saturation = math.clamp(1 - relative_palette.X / windowcolor.AbsoluteSize.X, 0, 1);
                    value = math.clamp(1 - relative_palette.Y / windowcolor.AbsoluteSize.Y, 0, 1);
                end

                if sliding_hue and library:is_mouse_over_frame(windowhue) then
                    hue = math.clamp(1 - relative_hue.Y / windowhue.AbsoluteSize.Y, 0, 1);
                    huedragger.Position = UDim2.new(0,0,0,relative_hue.Y)
                end

                hsv = Color3.fromHSV(hue, saturation, value);
                tween_service:Create(windowcolor, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromHSV(hue, 1, 1)}):Play();
                tween_service:Create(colorbutton, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = hsv}):Play();
                
                windowdragger.Position = UDim2.new(math.clamp(1 - saturation, 0, 1 - 0.025), 0, math.clamp(1 - value, 0, 1 - 0.024), 0);
                library.flags[colorpicker.flag] = hsv;
                colorpicker.callback(hsv);
            end

            local function _set(colora, a)
                if type(colora) == "table" then
                    a = colora[4]
                    colora = Color3.fromHSV(colora[1], colora[2], colora[3])
                end
                if type(colora) == "string" then
                    colora = Color3.fromHex(colora)
                end

                local oldcolor = hsv
                local oldalpha = alpha 

                hue, saturation, value = colora:ToHSV()
                alpha = a or 1
                hsv = Color3.fromHSV(hue, saturation, value)

                if hsv ~= oldcolor then
                    tween_service:Create(windowcolor, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = Color3.fromHSV(hue, 1, 1)}):Play();
                    tween_service:Create(colorbutton, TweenInfo.new(library.tween_speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundColor3 = hsv}):Play();
                    windowdragger.Position = UDim2.new(math.clamp(1 - saturation, 0, 1 - 0.025), 0, math.clamp(1 - value, 0, 1 - 0.024), 0);
                    library.flags[colorpicker.flag] = hsv;
                    colorpicker.callback(hsv);
                end
            end

            library:connect(colorbutton.MouseButton1Down, set_open);

            library:connect(windowcolor.InputBegan, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding_palette = true;
                    set_state();
                end
            end)

            library:connect(windowcolor.InputEnded, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding_palette = false;
                end
            end)

            library:connect(windowhue.InputBegan, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding_hue = true;
                    set_state();
                end
            end)

            library:connect(windowhue.InputEnded, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding_hue = false;
                end
            end)

            library:connect(user_input_service.InputChanged, function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    if sliding_hue or sliding_palette then
                        set_state();
                    end
                end
            end)

            _set(colorpicker.state, colorpicker.alpha)
            return colorpicker
        end;

        function library.sections:keybind(options)
            local keybind = {
                section = self;
                name = options.name or 'keybind';
                state = options.state or nil;
                flag = options.flag or library:next_flag();
                mode = options.mode or 'Toggle';
                usekey = options.usekey or false;
                callback = options.callback or function() end;
                binding = nil;
            };

            local newkeybind = instance.new("Frame", {
                Name = "newkeybind";
                Parent = keybind.section.objects.main;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 15);
            })
            
            local text = instance.new("TextLabel", {
                Name = "text";
                Parent = newkeybind;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                FontFace = text_font;
                Text = keybind.name;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })
            
            local key = instance.new("TextButton", {
                Name = "key";
                Parent = newkeybind;
                AnchorPoint = Vector2.new(1, 0);
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 15, 0, 15);
                FontFace =text_font;
                Text = "[None]";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                AutomaticSize = Enum.AutomaticSize.X
            });

            do
                local c
                local Key
				local State = false
				-- // Functions
				local function set(newkey)
					if string.find(tostring(newkey), "Enum") then
						if c then
							c:Disconnect()
							library.flags[keybind.flag] = false
							keybind.callback(false)
						end
						if tostring(newkey):find("Enum.KeyCode.") then
							newkey = Enum.KeyCode[tostring(newkey):gsub("Enum.KeyCode.", "")]
						elseif tostring(newkey):find("Enum.UserInputType.") then
							newkey = Enum.UserInputType[tostring(newkey):gsub("Enum.UserInputType.", "")]
						end
						if newkey == Enum.KeyCode.Backspace then
							Key = nil
							if keybind.usekey then
								library.flags[keybind.flag] = key
								keybind.callback(Key)
							end
							local text = "[None]"

							key.Text = text
						elseif newkey ~= nil then
							Key = newkey
							if keybind.usekey then
								library.flags[keybind.flag] = key
								keybind.callback(Key)
							end
							local text = (library.Keys[newkey] or tostring(newkey):gsub("Enum.KeyCode.", ""))

							key.Text = `[{text}]`
						end

						library.flags[keybind.flag .. "_KEY"] = newkey
					elseif table.find({ "Always", "Toggle", "Hold" }, newkey) then
						if not keybind.usekey then
							library.flags[keybind.flag .. "_KEY STATE"] = newkey
							keybind.mode = newkey
							if keybind.mode == "Always" then
								State = true
								if keybind.flag then
									library.flags[keybind.flag] = State
								end
								keybind.callback(true)
							elseif keybind.mode == 'Hold' then
								State = false
								if keybind.flag then
									library.flags[keybind.flag] = State
								end
								keybind.callback(false)
							end
						end
					else
						State = newkey
						if keybind.flag then
							library.flags[keybind.flag] = newkey
						end
						keybind.callback(newkey)
					end
				end
				--
				set(keybind.state)
				set(keybind.mode)
				key.MouseButton1Click:Connect(function()
					if not keybind.binding then

						key.Text = "..."

						keybind.binding = library:connect(
							game:GetService("UserInputService").InputBegan,
							function(input, gpe)
								set(
									input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode
										or input.UserInputType
								)
								library:disconnect(keybind.binding)
								task.wait()
								keybind.binding = nil
							end
						)
					end
				end)
				--
				library:connect(game:GetService("UserInputService").InputBegan, function(inp)
					if (inp.KeyCode == Key or inp.UserInputType == Key) and not keybind.binding and not keybind.usekey then
						if keybind.mode == "Hold" then
							if keybind.flag then
								library.flags[keybind.flag] = true
							end
							c = library:connect(game:GetService("RunService").RenderStepped, function()
								if keybind.callback then
									keybind.callback(true)
								end
							end)
						elseif keybind.mode == "Toggle" then
							State = not State
							if keybind.flag then
								library.flags[keybind.flag] = State
							end
							keybind.callback(State)
						end
					end
				end)
				--
				library:connect(game:GetService("UserInputService").InputEnded, function(inp)
					if keybind.mode == "Hold" and not keybind.usekey then
						if Key ~= "" or Key ~= nil then
							if inp.KeyCode == Key or inp.UserInputType == Key then
								if c then
									c:Disconnect()
									if keybind.flag then
										library.flags[keybind.flag] = false
									end
									if keybind.callback then
										keybind.callback(false)
									end
								end
							end
						end
					end
				end)
            end

            return keybind;
        end;

        function library.sections:textbox(options)
            local textbox = {
                section = self;
                name = options.name or 'textbox',
                flag = options.flag or library:next_flag();
                placeholder = options.placeholder or '...';
                callback = options.callback or function() end;
                state = options.state or 'default',
            };

            local newbox = instance.new("Frame", {
                Name = "newbox";
                Parent = game.StarterGui.remakeui.mainframe.inline.content.tab.subtab.sectionholders.left.section.content;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 35);
            })
            
            local text = instance.new("TextLabel", {
                Name = "text";
                Parent = newbox;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 15);
                Font = Enum.Font.SciFi;
                Text = "textbox";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
                TextXAlignment = Enum.TextXAlignment.Left;
            })
            
            local outline = instance.new("Frame", {
                Name = "outline";
                Parent = newbox;
                AnchorPoint = Vector2.new(0, 1);
                BackgroundColor3 = Color3.fromRGB(34, 34, 34);
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 1, 0);
                Size = UDim2.new(1, 0, 0, 17);
            })

            local UIStroke = instance.new("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0);
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                Parent = outline;
            })
            
            local UIGradient = instance.new("UIGradient", {
                Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(150, 150, 150))};
                Parent = outline;
            })
            
            local inline = instance.new("TextBox", {
                Name = "inline";
                Parent = outline;
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 1.000;
                BorderColor3 = Color3.fromRGB(0, 0, 0);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                ClearTextOnFocus = false;
                Font = Enum.Font.SciFi;
                PlaceholderColor3 = Color3.fromRGB(178, 178, 178);
                PlaceholderText = textbox.placeholder;
                Text = "";
                TextColor3 = Color3.fromRGB(255, 255, 255);
                TextSize = 12.000;
                TextStrokeTransparency = 0.000;
            })

            library:connect(inline.FocusLost, function()
                local str = inline.Text;
                library.flags[textbox.flag] = str;
                textbox.callback(str);
            end)

            local _set = function(str)
                inline.Text = str;
                library.flags[textbox.flag] = str;
                textbox.callback(str);
            end

            _set(textbox.state)
            return textbox
        end
    end;
end

function library:get_library()
    return library;
end;

--[[
local window = library:window({name = 'samet<font color="rgb(160, 166, 255)">hack</font> - ratz$$'});

local rage = window:tab({name = "combat"});
local legit = window:tab({name = "misc"});
local hacl = window:tab({name = "hack"});
local settings_tab = window:tab({name = "settings"});

local silent_aim = rage:sub_tab({name = "silent aim"});
rage:sub_tab({name = "aimbot"});

local section = silent_aim:section({name = "section", side = "left"});
local library_settings = settings_tab:sub_tab({name = "UI"});
local grobx = library_settings:section({name = "main", side = "left"})

local aaaaa = section:toggle({name = "roblox hack", state = false, flag = "roblox hacks enabled", callback = function(v) print(v) end});
local settingsss = aaaaa:settings(112)
settingsss:toggle({name = "hack bitdancer", state = false, flag = "roblox hacks enabled", callback = function(v) print(v) end});
settingsss:toggle({name = "rarara", state = false, flag = "roblox hacks enabled", callback = function(v) print(v) end});
settingsss:toggle({name = "bully unvhook", state = false, flag = "roblox hacks enabled", callback = function(v) print(v) end});
settingsss:button({name = "hack bullets", callback = function() warn("pressed"); end});
settingsss:slider({name = "unvhook", min = 15, max = 25, decimals = 0.1, state = 17, suffix = "", flag = "Slider", Callback = function(v)print(v)end})

section:button({name = "hack bullets", callback = function() warn("pressed"); end});
section:slider({name = "slide", min = 15, max = 25, decimals = 0.1, state = 17, suffix = "", flag = "Slider", Callback = function(v)print(v)end})
section:dropdown({name = "person to burn", options = {"unvhook","nova (atg-external.sln)","zyzo","summon","merxy","isk"}, state = "zyzo", flag = "dropdown", multi = false, callback = function(v)print(v)end})
section:colorpicker({name = "burn color", flag = "Colorpicker", state = library.theme.accent, callback = function(v) print(v) end});
section:keybind({name = "keybind", state = nil, flag = "keybind", callback = function(v) print(v) end})

grobx:slider({name = "tween speed", min = 0, max = 1, decimals = 0.01, state = 0.1, suffix = "s", flag = "library_tween_speed", callback = function(v) library.tween_speed = v end});
grobx:slider({name = "max fps", min = 0, max = 999, decimals = 1, state = 60, suffix = " fps", flag = "set_fps_cap", callback = function(v) setfpscap(v) end});
--]]
getgenv().library = library;
return library;
