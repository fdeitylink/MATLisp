classdef Symbol < handle
  properties (Constant)
    Store = containers.Map
  end

  properties
    Name
  end

  methods (Static)
    function sym = intern(sym)
      store = Symbol.Store;
      if isKey(store, sym.Name)
        sym = store(sym.Name);
      else
        store(sym.Name) = sym;
      end
    end
  end

  methods
    function sym = Symbol(name)
      sym.Name = name;
      sym = Symbol.intern(sym);
    end
  end
end
