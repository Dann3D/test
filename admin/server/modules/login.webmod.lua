local RegisteredUsers = {}

function ParseUserPass(basic)
    local authorizationCode = basic:sub(string.len('Basic ')+1)
    return table.unpack( table.build( Base64.decode(authorizationCode):split(":") ) )
end

function AddUser(username, password, perms)
    RegisteredUsers[username] = {password=password, permission=json.decode(json.encode(perms))}
end

function user(username)
    return {
        password = function(_, password)
            return {
                permissions = function(_, perms)
                    AddUser(username, password, perms)
                end
            }
        end
    }
end

function CanLogin(user, password)
    if RegisteredUsers[user] ~= nil and RegisteredUsers[user].password == password then
        return true, RegisteredUsers[user].level
    end
    return false
end

function HasPermission(username, perm)
    return RegisteredUsers[username] ~= nil and RegisteredUsers[username].permission[perm] or false
end
