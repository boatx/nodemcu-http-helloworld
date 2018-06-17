local srv = net.createServer(net.TCP)
local state = gpio.HIGH

function init_server()

    local function load_template(template_name, default_value)
        if file.open(template_name) then
            return file.read()
        end

        return default_value
    end


    local pin = 4 --default nodemcu diode
    local template = load_template('template.html')
    local context = {}
    context[gpio.HIGH] = {'Turn ON', 'btn-primary'}
    context[gpio.LOW] = {'Turn OFF', 'btn-danger'}

    local function init_diode()
        --set pin into outpout mode
        gpio.mode(pin, gpio.OUTPUT)
        gpio.write(pin, state)
    end

    init_diode()

    local function is_post(data)
        return data:find("^POST") ~= nil
    end

    local function receiver(sck, data)

        local function toggle_diode()
            if state == gpio.LOW then
                state = gpio.HIGH
            else
                state = gpio.LOW
            end
            gpio.write(pin, state)
        end

        local function render_template()
            label, btn_cls = unpack(context[state])
            return template:gsub("{{label}}", label):gsub("{{btnclass}}", btn_cls)
        end

        local response = {}

        if is_post(data) then
            toggle_diode()
            response[#response + 1] = "HTTP/1.1 303 See Other\r\nLocation: http://"..ip_addr.."\r\nContent-Type: text/html\r\n\r\n"
        else
            response[#response + 1] = "HTTP/1.0 200 OK\r\nServer: NodeMCU on ESP8266\r\nContent-Type: text/html\r\n\r\n"
            response[#response + 1] = render_template()
        end

        local function send(local_socket)
            if #response > 0 then
            local_socket:send(table.remove(response, 1))
            else
            local_socket:close()
            response = nil
            end
        end

        --keep sending rospense elements as long response is not empty
        sck:on("sent", send)

        send(sck)
    end

    return receiver
end

srv:listen(80, function(conn)
  conn:on("receive", init_server())
end)
