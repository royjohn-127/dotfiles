-- Loaded by Clink in cmd.exe. Uses the same theme.txt as PowerShell.
-- Paths are found relative to this file, so the repo can live anywhere.
local dir = debug.getinfo(1, "S").source:sub(2):match("(.*)[/\\]")
if not dir then return end
local root = dir .. "/.."

local name = "minimal-clean"
local f = io.open(root .. "/theme.txt", "r")
if f then
  local line = f:read("*l")
  f:close()
  local candidate = line and line:match("^%s*(.-)%s*$")
  -- Only plain file names are accepted: this value ends up in a shell command.
  if candidate and candidate:match("^[%w_.%-]+$") then name = candidate end
end

local theme = root .. "/themes/" .. name .. ".omp.json"
load(io.popen('oh-my-posh init cmd --config "' .. theme .. '"'):read("*a"))()
