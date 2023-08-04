local function no_scheme(name)
  return string.find(name, "://") == nil
end

-- Process links to markdown and convert to html
function Link(l)
  if no_scheme(l.target) then
    l.target = string.gsub(l.target, "%.md", ".html")
  end
  return l
end
