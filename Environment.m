classdef Environment
  properties
    Parent
    Store
  end

  methods
    function env = Environment()
      env.Store = containers.Map;
      env.Parent = NaN;
    end

    function set(env, name, value)
      if ~strcmp(class(name), 'Symbol')
        error("name must be a symbol");
      else
        env.Store(name.Name) = value;
      end
    end

    function entry = lookup(env, name)
      if isKey(env.Store, name.Name)
        entry = {name env.Store(name.Name)};
      elseif strcmp(class(env.Parent), 'double') && ~isnan(env.Parent)
        entry = env.Parent.lookup(env, name);
      else
        entry = NaN;
      end
    end

    function value = find(env, name)
      entry = env.lookup(name);
      if strcmp(class(entry), 'cell')
        value = entry{2};
      else
        value = NaN;
      end
    end

    function value = get(env, name)
      entry = env.lookup(name);
      if strcmp(class(entry), 'cell')
        value = entry{2};
      else
        error("name unbound");
      end
    end
  end
end
