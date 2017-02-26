-- ## util
--
local util = {}

-- ### util.isCallable
--
-- Returns true if variable 'x' is a function or a callable table.
--
-- 'x' is a variable
--
function util.isCallable(x)
    if type(x) == "function" then return true end
    local mt = getmetatable(x)
    return mt and mt.__call ~= nil
end

-- ### util.tablefind
--
-- Find a 'value' in the table 't' and return its index.
--
-- 't'     is a table
-- 'value' is the value
--
function util.tableFind(t, value)
    for index, val in pairs(t) do
        if val == value then
            return index
        end
    end
end

-- ### util.printTable
--
-- Print a table 't' and all its elements. Prints nested tables recursively.
--
-- 't' is a table
--
function util.printTable(t)
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

return util
