classdef RegisterFile < handle
   properties (Hidden)
      AccountStatus = 'open'; 
   end
   % The following properties can be set only by class methods
   properties (SetAccess = private)
      NoEntries
      Contents = zeros(1,NoEntries); 
   end
   events
      
   end
   methods
      function RF = RegisterFile(Entries,InitialBalance)
         RF.NoEntries = Entries;
         RF.Contents = [];
      end
      function read(RF, address)
        returnValue = RF.Contents(address)
        return returnValue
      end
      function write(RF, address, data)
         RF.Contents(address) = data;
      end % write
   end % methods
end % classdef