classdef OpenEpBuildingBlock
    %OPENEPBUILDINGBLOCK Summary of this class goes here
    %   An OPENEPBUILDINGBLOCK object is used to execute OpenEP function
    %   calls which are encapsulated (described) in OpenEP workflow .xml
    %   files.
    %
    %   Example:
    %       workflowblock1 = OpenEpBuildingBlock('/Users/steven/Dropbox/Matlab_Code/workingdir/openep-workflows/def/loadOpenEpData.xml');
    %       workflowblock2 = OpenEpBuildingBlock('/Users/steven/Dropbox/Matlab_Code/workingdir/openep-workflows/def/getVoltageMaps.xml');

    properties (Access = public)
        name
        author
        date
        license
        description
        xmlPath

        % these properties allow a work flow block to be displayed with
        % options
        inputs
        outputs

        % these properties define the actual function call
        functionCall

        % this property defines the chain of events
        hasPrevious
        previousBuildingBlock
    end

    properties (Access = private)
        openEpFunction

    end

    methods
        function obj = OpenEpBuildingBlock(xmlFilePath)
            %OPENEPBUILDINGBLOCK Construct an instance of this class
            %   The constructor reads the contents of the XML file and
            %   creates an OpenEpBuildingBlock object. The only properties
            %   that are assigned within the constructor are those which
            %   have been read from the XML file. This prevents us having
            %   to read the XML file later whilst not undertaking
            %   unnecessary processing at this stage which might never be
            %   needed if the building block is not used.

            obj.xmlPath = xmlFilePath;
            workflowblock = xml_read(obj.xmlPath);

            % store the metadata
            obj.name = workflowblock.metadata.name;
            obj.author = workflowblock.metadata.author;
            obj.date = workflowblock.metadata.date;
            obj.license = workflowblock.metadata.license;
            obj.description = workflowblock.metadata.description;

            % store the OpenEP function
            obj.openEpFunction = workflowblock.openepfunction.functionname;

            % parse the inputs
            numInputs = numel(workflowblock.inputs.input);
            for i = 1:numInputs
                obj.inputs{i}.name = workflowblock.inputs.input(i).CONTENT;
                obj.inputs{i}.type = workflowblock.inputs.input(i).ATTRIBUTE.type;
                switch obj.inputs{i}.type
                    case 'select'
                        try
                            obj.inputs{i}.options = strsplit(workflowblock.inputs.input(i).ATTRIBUTE.options);
                        end
                    case 'numeric'
                        try
                            obj.inputs{i}.range = workflowblock.inputs.input(i).ATTRIBUTE.range;
                        end
                end
            end

            % parse the outputs
            numOutputs = numel(workflowblock.outputs.output);
            for i = 1:numOutputs
                obj.outputs{i}.name = workflowblock.outputs.output(i).CONTENT;
                obj.outputs{i}.type = workflowblock.outputs.output(i).ATTRIBUTE.type;
            end

            %obj.hasPrevious

        end

        function save(obj)
            %OPENEPBUILDINGBLOCK/SAVE Writes XML files describing this
            %   object

            % update the workflowblock with each property

            % write the workflowblock to file
            xml_write(obj.xmlPath, workflowblock)
        end

        function obj = parseFunctionCall(obj)
            %OPENEPBUILDINGBLOCK/PARSEFUNCTIONCALL creates the required 
            %   OpenEP function call from this object which
            workflowblock = xml_read(obj.xmlPath);

            % parse the arguments
            numArgs = numel(workflowblock.openepfunction.essential.argument);
            for i = 1:numArgs
                order(i) = workflowblock.openepfunction.essential.argument(i).position;
            end
            if numel(unique(order)) ~= numel(order)
                error('OPENEP/OPENEPBUILDINGBLOCK: Multiple arguments have been given the same position in the XML specification file');
            end
            essentialArguments = '';
            for i = 1:numArgs
                iArg = order(i);
                nameArg = workflowblock.openepfunction.essential.argument(iArg).value;
                if isempty(essentialArguments)
                    essentialArguments = nameArg;
                else
                essentialArguments = [essentialArguments ...
                    ', ' ...
                    nameArg]; %#ok<*AGROW> 
                end
            end

            obj.functionCall = [ obj.openEpFunction ...
                '(' ...
                essentialArguments ...
                ')' ...
                ];
        end

        function execute(obj)
            
            % create the function call
            parseFunctionCall(obj);

            % first execute any previous function calls
            if obj.hasPrevious
                output = obj.previousBuildingBlock.execute();
            end

            % convert into variables in the local space
            for i = 1:numel(output)
                eval(sprintf('%s = %g', output(1).name, output(1).value));
            end

            % execute the function call
            eval(obj.functionCall);
        end
    end
end