local drawing = {
    fonts = {
        verdana = 0;
        smallestpixel7 = 1;
        proggy = 2;
        minecraftia = 3;
        verdanabold = 4;
        tahoma = 5;
        tahomabold = 6;        
    };
    directory = nil;
    count = 0;
};

local http_service = game:GetService("HttpService");

local objects = {
    inew = Instance.new;
    u2new = UDim2.new;
    unew = UDim.new;
    v2new = Vector2.new;
    rgb = Color3.fromRGB;
    -- 
    deg = math.deg;
    atan2 = math.atan2;
    min = math.min;
    max = math.max;
};

-- Custom Fonts
local fonts = {
    { ttf = "Proggy.ttf", json = "Proggy.json", url = "https://raw.githubusercontent.com/OxygenClub/Random-LUAS/main/Proggy.txt", name = "Proggy" },
    { ttf = "Minecraftia.ttf", json = "Minecraftia.json", url = "https://raw.githubusercontent.com/OxygenClub/Random-LUAS/main/Minecraftia.txt", name = "Minecraftia" },
    { ttf = "SmallestPixel7.ttf", json = "SmallestPixel7.json", url = "https://raw.githubusercontent.com/OxygenClub/Random-LUAS/main/Smallest%20Pixel.txt", name = "SmallestPixel7" },
    { ttf = "Verdana.ttf", json = "Verdana.json", url = "https://raw.githubusercontent.com/OxygenClub/Random-LUAS/main/Verdana.txt", name = "Verdana" },
    { ttf = "VerdanaBold.ttf", json = "VerdanaBold.json", url = "https://raw.githubusercontent.com/OxygenClub/Random-LUAS/main/Verdana%20Bold.txt", name = "VerdanaBold" },
    { ttf = "Tahoma.ttf", json = "Tahoma.json", url = "https://raw.githubusercontent.com/OxygenClub/Random-LUAS/main/Tahoma.txt", name = "Tahoma" },
    { ttf = "TahomaBold.ttf", json = "TahomaBold.json", url = "https://raw.githubusercontent.com/OxygenClub/Random-LUAS/main/Tahoma%20Bold.txt", name = "TahomaBold" }
}

for _, font in fonts do
    if not isfile(font.ttf) then
        writefile(font.ttf, base64_decode(game:HttpGet(font.url)));
    end

    if not isfile(font.json) then
        local font_config = {
            name = font.name;
            faces = {
                {
                    name = "Regular";
                    weight = 200;
                    style = "normal";
                    assetId = getcustomasset(font.ttf);
                };
            };
        };
        writefile(font.json, http_service:JSONEncode(font_config));
    end


end;

local drawing_fonts = {
    [0] = Font.new(getcustomasset("Verdana.json"), Enum.FontWeight.Regular);
    [1] = Font.new(getcustomasset("SmallestPixel7.json"), Enum.FontWeight.Regular);
    [2] = Font.new(getcustomasset("Proggy.json"), Enum.FontWeight.Regular);
    [3] = Font.new(getcustomasset("Minecraftia.json"), Enum.FontWeight.Regular);
    [4] = Font.new(getcustomasset("VerdanaBold.json"), Enum.FontWeight.Regular);
    [5] = Font.new(getcustomasset("Tahoma.json"), Enum.FontWeight.Regular);
    [6] = Font.new(getcustomasset("TahomaBold.json"), Enum.FontWeight.Regular);
}

local function get_font_from_index(a)
    return drawing_fonts[a];
end

local function create_instance(class, properties)
    local object =  objects.inew(class);

    for property, value in properties do
        object[property] = value;
    end

    return object
end

local function create_outline(object, color, thickness)
    local outline = create_instance("UIStroke", {
        Enabled = true;
        Parent = object;
        Color = color;
        Thickness = thickness;
        Transparency = 0;
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
    })

    return outline
end

local function create_gradient(object, rotation, c1, c2)
    local gradient = create_instance("UIGradient", {
        Parent = object;
        Rotation = rotation;
        Color = ColorSequence.new{ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)};
    })

    return gradient
end

local function create_rounding(object, radius)
    local rounding = create_instance("UICorner", {
        Parent = object;
        CornerRadius = radius;
    })

    return rounding
end

local drawing_directory; drawing_directory = create_instance("ScreenGui", {
    IgnoreGuiInset = true;
    Parent = gethui();
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
})

drawing.directory = drawing_directory;

function drawing.create(class: string, properties: table)
    properties = properties or {};

    if class == "line" then
        local actualline = {};
        local line = create_instance("Frame", {
            Parent = drawing.directory;
            BackgroundColor3 = properties.color;
            BorderSizePixel = 0;
            AnchorPoint = objects.v2new(0.5,0.5);
            Visible = properties.visible;
        })

        local line_outline;
        local line_gradient;

        local from = properties.from;
        local to = properties.to;
        local thickness = properties.thickness;

        local outline_table = properties.outline
        local outline = properties.outline.enabled
        local outline_color = properties.outline.color;
        local outline_thickness = properties.outline.thickness;

        local gradient_table = properties.gradient;
        local gradient = properties.gradient.enabled;
        local gradient_color1 =  properties.gradient.color1;
        local gradient_color2 =   properties.gradient.color2;
        local gradient_rotation =   properties.gradient.rotation;

        if from and to and thickness then
            local position = (from + to) / 2
            local length = (from - to).Magnitude
            local rotation = objects.deg(objects.atan2(to.Y - from.Y, to.X - from.X))
            line.Size = objects.u2new(0, length, 0, thickness);
            line.Position = objects.u2new(0,position.X,0,position.Y);
            line.Rotation = rotation
        end

        if outline_table and outline and outline_color and outline_thickness then
            line_outline = create_outline(line, outline_color, outline_thickness);
            line_outline.Enabled = outline
        end

        if gradient_table and gradient and gradient_color2 and gradient_color1 then
            line_gradient = create_gradient(line, gradient_rotation, gradient_color1, gradient_color2);
            line_gradient.Enabled = gradient;
        end

        function actualline:setthickness(v)
            if from and to and v then
                local position = (from + to) / 2
                local length = (from - to).Magnitude
                local rotation = objects.deg(objects.atan2(to.Y - from.Y, to.X - from.X))
                line.Size = objects.u2new(0, length, 0, v);
                line.Position = objects.u2new(0,position.X,0,position.Y);
                line.Rotation = rotation
            end
        end

        function actualline:setfrom(v)
            if v and to and thickness then
                local position = (v + to) / 2
                local length = (v - to).Magnitude
                local rotation = objects.deg(objects.atan2(to.Y - v.Y, to.X - v.X))
                line.Size = objects.u2new(0, length, 0, thickness);
                line.Position = objects.u2new(0,position.X,0,position.Y);
                line.Rotation = rotation
            end
        end

        function actualline:setto(v)
            if from and v and thickness then
                local position = (from + v) / 2
                local length = (from - v).Magnitude
                local rotation = objects.deg(objects.atan2(v.Y - from.Y, v.X - from.X))
                line.Size = objects.u2new(0, length, 0, thickness);
                line.Position = objects.u2new(0,position.X,0,position.Y);
                line.Rotation = rotation
            end
        end

        function actualline:setoutlinevisibility(v)
            line_outline.Enabled = v
        end

        function actualline:setoutlinethickness(v)
            line_outline.Thickness = v
        end

        function actualline:setoutlinecolor(v)
            line_outline.Color = v
        end

        function actualline:setgradientvisiblity(v)
            line_gradient.Enabled = v;
        end

        function actualline:setgradientrotation(v)
            line_gradient.Rotation = v;
        end

        function actualline:setgradientcolor(v,a)
            line_gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, v), ColorSequenceKeypoint.new(1, a)};
        end

        return actualline
    elseif class == "circle" or class == "square" then
        local actualcircle = {};
        local circle = create_instance("Frame", {
            Parent = drawing.directory;
            BackgroundColor3 = properties.color;
            BorderSizePixel = 0;
            AnchorPoint = objects.v2new(0.5,0.5);
            BackgroundTransparency = 1;
            Visible = properties.visible;
            Size = objects.u2new(0, properties.radius * 1.3, 0, properties.radius * 1.3);
            Position = objects.u2new(0, properties.position.X, 0, properties.position.Y);
        })

        local thickness = properties.thickness;
        local circle_gradient;

        local gradient_table = properties.gradient;
        local gradient = properties.gradient.enabled;
        local gradient_color1 =  properties.gradient.color1;
        local gradient_color2 =   properties.gradient.color2;
        local gradient_rotation =   properties.gradient.rotation;

        local rounding = create_rounding(circle, objects.unew(1,0));
        local outline = create_outline(circle, properties.color, thickness);

        if class == "square" then
            rounding.CornerRadius = objects.unew(0,0)
        end

        if gradient_table and gradient and gradient_color2 and gradient_color1 then
            circle_gradient = create_gradient(outline, gradient_rotation, gradient_color1, gradient_color2);
            circle_gradient.Enabled = gradient;
        end

        function actualcircle:setrounding(type)
            rounding.CornerRadius = type == "square" and objects.unew(0,0) or objects.unew(1,0)
        end

        function actualcircle:setcirclesize(size)
            circle.Size = objects.u2new(0, size * 1.3, 0, size * 1.3);
        end

        function actualcircle:setcircleposition(v2new)
            circle.Position = objects.u2new(0, v2new.X, 0, v2new.Y);
        end

        function actualcircle:setgradientvisiblity(v)
            circle_gradient.Enabled = v;
        end

        function actualcircle:setgradientrotation(v)
            circle_gradient.Rotation = v;
        end

        function actualcircle:setgradientcolor(v,a)
            circle_gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, v), ColorSequenceKeypoint.new(1, a)};
        end

        return actualcircle;
    elseif class == "quad" then
        local actualquad = {};
        local quad = create_instance("Frame", {
            Parent = drawing_directory;
            BackgroundTransparency = properties.transparency;
            Size =objects.u2new(0, properties.size.X * 1.3, 0, properties.size.Y * 1.3);
            Visible = properties.visible;
        })
        local quad_gradient
        local quad_outline

        local minX, minY, maxX, maxY = properties.points[1].X, properties.points[1].Y, properties.points[1].X, properties.points[1].Y

        for _, point in ipairs(properties.points) do
            minX = objects.min(minX, point.X)
            minY = objects.min(minY, point.Y)
            maxX = objects.max(maxX, point.X)
            maxY = objects.max(maxY, point.Y)
        end

        quad.Position = objects.u2new(0, minX,0 ,minY);
        quad.Size = objects.u2new(0, maxX - minX, 0, maxY - minY);

        local outline_table = properties.outline
        local outline = properties.outline.enabled
        local outline_color = properties.outline.color;
        local outline_thickness = properties.outline.thickness;

        local gradient_table = properties.gradient;
        local gradient = properties.gradient.enabled;
        local gradient_color1 =  properties.gradient.color1;
        local gradient_color2 =   properties.gradient.color2;
        local gradient_rotation =   properties.gradient.rotation;

        if outline_table and outline and outline_color and outline_thickness then
            quad_outline = create_outline(quad, outline_color, outline_thickness);
            quad_outline.Enabled = outline
        end

        if gradient_table and gradient and gradient_color2 and gradient_color1 then
            quad_gradient = create_gradient(quad, gradient_rotation, gradient_color1, gradient_color2);
            quad_gradient.Enabled = gradient;
        end

        function actualquad:setnewpoints()
            local minX, minY, maxX, maxY = properties.points[1].X, properties.points[1].Y, properties.points[1].X, properties.points[1].Y

            for _, point in ipairs(properties.points) do
                minX = objects.min(minX, point.X)
                minY = objects.min(minY, point.Y)
                maxX = objects.max(maxX, point.X)
                maxY = objects.max(maxY, point.Y)
            end

            quad.Position = objects.u2new(0, minX,0 ,minY);
            quad.Size = objects.u2new(0, maxX - minX, 0, maxY - minY);
        end

        function actualquad:setoutlinevisibility(v)
            quad_outline.Enabled = v
        end

        function actualquad:setoutlinethickness(v)
            quad_outline.Thickness = v
        end

        function actualquad:setoutlinecolor(v)
            quad_outline.Color = v
        end

        function actualquad:setgradientvisiblity(v)
            quad_gradient.Enabled = v;
        end

        function actualquad:setgradientrotation(v)
            quad_gradient.Rotation = v;
        end

        function actualquad:setgradientcolor(v,a)
            quad_gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, v), ColorSequenceKeypoint.new(1, a)};
        end

        return actualquad
    elseif class == "text" then
        local actualtext = {};
        local text = create_instance("TextLabel", {
            Parent = drawing_directory;
            BorderSizePixel = 0;
            Visible = properties.visible;
            TextColor3 = properties.color;
            BackgroundTransparency = 1;
            AutomaticSize = Enum.AutomaticSize.XY;
            Position = objects.u2new(0, properties.position.X, 0, properties.position.Y);
            Text = properties.text;
            FontFace = get_font_from_index(properties.font);
            TextStrokeTransparency = properties.stroke_transparency;
            TextStrokeColor3 = Color3.fromRGB(0,0,0);
            TextSize = properties.size;
        });

        local text_gradient;
        local text_outline;

        local gradient_table = properties.gradient;
        local gradient = properties.gradient.enabled;
        local gradient_color1 =  properties.gradient.color1;
        local gradient_color2 =   properties.gradient.color2;
        local gradient_rotation =   properties.gradient.rotation;

        local outline_table = properties.outline
        local outline = properties.outline.enabled
        local outline_color = properties.outline.color;
        local outline_thickness = properties.outline.thickness;

        if gradient_table and gradient and gradient_color2 and gradient_color1 then
            text_gradient = create_gradient(text, gradient_rotation, gradient_color1, gradient_color2);
            text_gradient.Enabled = gradient;
        end

        if outline_table and outline and outline_color and outline_thickness then
            text_outline = create_outline(text, outline_color, outline_thickness);
            text_outline.Enabled = outline
        end

        function actualtext:settext(v)
            text.Text = v;
        end

        function actualtext:setposition(v2)
            text.Position = objects.u2new(0, v2.X, 0, v2.Y);
        end

        function actualtext:setgradientvisiblity(v)
            text_gradient.Enabled = v;
        end

        function actualtext:setgradientrotation(v)
            text_gradient.Rotation = v;
        end

        function actualtext:setgradientcolor(v,a)
            text_gradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, v), ColorSequenceKeypoint.new(1, a)};
        end

        function actualtext:setoutlinevisibility(v)
            text_outline.Enabled = v
        end

        function actualtext:setoutlinethickness(v)
            text_outline.Thickness = v
        end

        function actualtext:setoutlinecolor(v)
            text_outline.Color = v
        end

        return actualtext
    end
end

local line = drawing.create("line", {
    color = Color3.fromRGB(255,255,255), 
    visible = true, 
    from = Vector2.new(0,0), 
    to = Vector2.new(200,200), 
    thickness = 1;
    outline = {
        enabled = true;
        color = Color3.fromRGB(0,0,0);
        thickness = 1
    };
    gradient = {
        enabled = true;
        color1 = Color3.fromRGB(255,255,255);
        color2 = Color3.fromRGB(0,0,0);
        rotation = 0;
    }
})

local circle = drawing.create("circle", {
    color = Color3.fromRGB(255,255,255), 
    visible = true, 
    radius = 120,
    position = Vector2.new(125,125);
    thickness =  2;
    gradient = {
        enabled = true;
        color1 = Color3.fromRGB(255,255,255);
        color2 = Color3.fromRGB(0,0,0);
        rotation = 0;
    }
})

local square = drawing.create("square", {
    color = Color3.fromRGB(255,255,255), 
    visible = true, 
    radius = 120,
    position = Vector2.new(125,125);
    thickness =  2;
    gradient = {
        enabled = true;
        color1 = Color3.fromRGB(255,255,255);
        color2 = Color3.fromRGB(0,0,0);
        rotation = 0;
    }
})

local text = drawing.create("text", {
    color = Color3.fromRGB(255,255,255);
    size = 12,
    position = Vector2.new(125,125),
    text = "samet_drawing_library",
    stroke_transparency = 0;
    font = 2;
    gradient = {
        enabled = true;
        color1 = Color3.fromRGB(255,255,255);
        color2 = Color3.fromRGB(0,0,0);
        rotation = 0;
    };
    outline = {
        enabled = true;
        color = Color3.fromRGB(0,0,0);
        thickness = 1
    };
})

function drawing:get_library()
    return drawing
end

return drawing
