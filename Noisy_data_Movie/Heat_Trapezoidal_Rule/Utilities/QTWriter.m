classdef QTWriter < handle
    %QTWriter  Create a QuickTime movie writer object.
    %   
    %   OBJ = QTWriter(FILENAME) constructs a QTWriter object to write QuickTime
    %   movie data to a '.mov' file using lossless Photo PNG compression.
    %   FILENAME is a string enclosed in single quotation marks that specifies
    %   the name of the file to create. If filename does not include an
    %   extension the QTWriter constructor appends the '.mov' extension. The
    %   FILENAME can include an absolute or relative path.
    %
    %   OBJ = QTWriter(...,'PropertyName','PropertyValue',...) specifies options
    %   via property name-value pairs. The default movie format compression
    %   (codec) is lossless 'Photo PNG', but the lossy 'Photo JPEG' format can
    %   be specified via the 'MovieFormat' property. The lossless 'Photo TIFF'
    %   format yields larger file sizes than Photo PNG, but is faster (using LZW
    %   or the default PackBits 'CompressionType'). See below for a list of
    %   other supported property names and associated values.
    %
    %   Methods:
    %       close              - Close file after writing movie data.
    %       delete             - Delete object and assosciated files.
    %       writeMovie(FRAME)  - Write movie data to file.
    %
    %   Properties:
    %       BitDepth           - Number of bits per color channel in each output
    %                            movie frame. Only 8-bit encoding (8-bit
    %                            grayscale, 24-bit RGB, and 32-bit RGB with
    %                            transparency) is supported. (Read-only,
    %                            specified in the object constructor).
    %       ColorSpace         - String indicating the color mode of the movie, 
    %                            'rgb' or 'grayscale'. If grayscale is
    %                            specified and the input data is truecolor
    %                            (3 channels) it will be converted. If the
    %                            Transparency property has been set to true,
    %                            grayscale data (1 channel) will be be converted
    %                            to an equivalent 3-channel represntation and
    %                            opaque alpha channel added. (Read-only,
    %                            specified in the object constructor).
    %       ColorChannels      - Integer specifying the number of color channels
    %                            in the output movie: 1 for grayscale movies,
    %                            3 for truecolor RGB movies, and 4 for movies
    %                            where the Transparency property has been set
    %                            (Photo PNG only). (Read-only, based on the
    %                            movie format and the ColorSpace and
    %                            Transparency properties).
    %       CompressionMode    - String indicating if the selected movie format
    %                            is 'lossy' or 'lossless'. The Photo PNG and
    %                            Photo TIFF formats only support lossless
    %                            compression and the Photo JPEG format only
    %                            supports lossy compression. (Read-only).
    %       CompressionType    - String indicating the type compression to use
    %                            (Photo TIFF only). Supported algorithms are
    %                            'lzw', 'none', and 'packbits' (default).
    %                            PackBits compression will yield larger file
    %                            sizes compared to LZW compression, but writing
    %                            each frame is faster overall. (Read-only,
    %                            specified in the object constructor).
    %       Duration           - Current movie duration in seconds, based on the
    %                            value of TimeScale and the FrameRate for each
    %                            frame. (Read-only).
    %       FileName           - String specifying the name (and, optionally,
    %                            the path) of the movie file. (Read-only,
    %                            specified in the object constructor).
    %       FrameCount         - Number of frames written to the movie file.
    %                            (Read-only).
    %       FrameRate          - The current rate of playback of the movie in
    %                            frames per second. A positive scalar value.
    %                            Default is 20. Continuously variable
    %                            frame-rates are supported.
    %       Height             - Height of each movie frame in pixels.
    %                            (Read-only, the writeMovie method sets values
    %                            for Height and Width based on the dimensions 
    %                            of the first frame. The frame size must remain
    %                            fixed).
    %       Loop               - String indicating the type of looping behavior:
    %                            'none' (default), 'loop', or 'backandforth'.
    %       MaxFrameRate       - Current maximum frame rate in frames per
    %                            second. (Read-only).
    %       MeanFrameRate      - Current average frame rate of the movie in
    %                            frames per second. (Read-only).
    %       MinFrameRate       - Current minimum frame rate in frames per
    %                            second. (Read-only).
    %       MovieFormat        - String indicating the QuickTime movie format
    %                            (codec) to be used for compression. Supported
    %                            formats are 'Photo PNG' (default), 'Photo
    %                            JPEG', and 'Photo TIFF'. (Read-only, specified
    %                            in the object constructor).
    %       PlayAllFrames      - Boolean (true or false) indicating if the
    %                            'Play All Frames' flag should be set in the
    %                            movie file. Default is false.
    %       Quality            - Number between 0 through 100 indicating level
    %                            of compression for lossy formats (Photo JPEG).
    %                            Higher quality numbers result in higher movie
    %                            quality and larger file sizes. Lower quality
    %                            numbers result in lower movie quality and
    %                            smaller file sizes. Default is 100. (Read-only,
    %                            specified in the object constructor).
    %       TimeScale          - A positive integer greater than zero indicating
    %                            the number of discrete ticks per second that
    %                            the frame-rate is scaled in relation to.
    %                            Larger time-scale values allow greater temporal
    %                            resolution. Default is 10,000.
    %       Transparency       - Boolean (true or false) indicating if alpha
    %                            channel data is present and should be exported
    %                            (Photo PNG only). If the Transparency property
    %                            is set to true and the input data does not have
    %                            an alpha channel, it will be set to opaque. If
    %                            the Transparency property is set to false or is
    %                            not supported by the MovieFormat, any alpha
    %                            data will be ignored. Read-only, specified in
    %                            the object constructor).
    %       Width              - Width of each movie frame in pixels.
    %                            (Read-only, the writeMovie method sets values
    %                            for Height and Width based on the dimensions of
    %                            the first frame. The frame size must remain
    %                            fixed).
    %
    %   Example:
    %       
    %       % Prepare new movie file using the default PNG compression
    %       movObj = QTWriter('peaks.mov');
    %       
    %       % Create an animation
    %       hf = figure; Z = peaks; surfc(Z); frames = 100;
    %       axis tight; set(hf,'DoubleBuffer','on');
    %       set(gca,'nextplot','replacechildren');
    %       
    %       % Animate plot and write movie
    %     	for k = 0:frames
    %           hs = surfc(sin(2*pi*k/frames)*Z,Z);
    %           set(hs,'FaceColor','interp','FaceLighting','phong');
    %           light('Position',[0 0 4]);
    %           
    %           % Vary the frame-rate
    %           movObj.FrameRate = k;
    %           
    %           % Write each frame to the file
    %           writeMovie(movObj,getframe(hf));
    %       end
    %       
    %       % Set palindromic looping flag
    %       movObj.Loop = 'backandforth';
    %       
    %       % Finish writing movie and close file
    %       close(movObj);
    %
    %   See also:
    %       QTWriter/writeMovie, QTWriter/close, QTWriter/delete,
    %       QTWriter/install
    
    %   Inspired by MakeQTMovie, Malcolm Slaney, Interval Research, March 1999.
    %   Partially based on the VideoWriter class in Matlab R2011b.
    
    %   References:
    %       https://engineering.purdue.edu/~malcolm/interval/1999-066/
    %       http://developer.apple.com/library/mac/#documentation/QuickTime/QTFF
    
    %   QTWriter saves temporary images to disk via the writMovie method. These
    %   images are assembled into a movie when the close method is called. The
    %   full QuickTime header is written at the beginning of the movie file.
    %   Clearing the QTWriter object or calling close calls the delete method,
    %   which attempts to remove all of the temporary images and assosciated
    %   memory used by the object.
    
    %   Andrew D. Horchler, horchler @ gmail . com
    %   Created: 10-3-11, Revision: 1.1, 12-7-13
    %
    %   Copyright (c) 2012-2017, Andrew D. Horchler
    %   All rights reserved.
    %
    %   Redistribution and use in source and binary forms, with or without
    %   modification, are permitted provided that the following conditions are
    %   met:
    %     * Redistributions of source code must retain the above copyright
    %       notice, this list of conditions and the following disclaimer.
    %     * Redistributions in binary form must reproduce the above copyright
    %       notice, this list of conditions and the following disclaimer in the
    %       documentation and/or other materials provided with the distribution.
    %     * Neither the name of Case Western Reserve University nor the names of
    %       its contributors may be used to endorse or promote products derived
    %       from this software without specific prior written permission.
    %
    %       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    %       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    %       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    %       FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ANDREW D.
    %       HORCHLER BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    %       EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    %       PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    %       PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
    %       OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    %       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
    %       USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
    %       DAMAGE.
    
    
    properties (SetAccess=private)
        MovieFormat
        FileName
        ColorSpace
        BitDepth
        ColorChannels
        Transparency
        CompressionMode
        CompressionType
        Quality = 100;
        Width = 0;
        Height = 0;
    end
    
    properties
        FrameRate = 20;
    end
    
    properties (SetAccess=private)
        FrameCount = 0;
        MeanFrameRate
        MaxFramRate;
        MinFramRate
        Duration = 0;
    end
    
    properties
        TimeScale = 1e4;
        Loop = 'none';
        PlayAllFrames = false;
    end
    
    properties (SetAccess=private,Hidden,Transient)
        IsOpen = false;     % Indicates if the movie file is open for writing
    end
    
    properties (Access=private)
        FrameLengths = [];  % Vector of frame data sizes in bytes
        FrameRates = [];    % Vector of instantaneous frame rates for each frame
        FrameStarts = [];
        MovieFileID = -1;
        MovieFileName = '';	% The name of the movie file to be written
        MovieFilePath = '';	% The path to the movie file to be written
        MovieProfile = [];
        TmpImgName = '';
    end
    
    % ==========================================================================
    
    methods
        
        function MovieObject = QTWriter(filename,varargin)
            if nargin < 1
                error('QTWriter:QTWriter:NoFilename',...
                      'A file name must be specified.');
            end

            % Check that provided path and extension are valid
            filename = QTWriter.validatefilepath(filename,'.mov');

            % Check if file can be created or overwritten, output full path
            filename = QTWriter.validatefile(filename);

            % Set public and private filename properties
            MovieObject.FileName = filename;
            [filePath,file,fileExtension] = fileparts(filename);
            MovieObject.MovieFileName = [file fileExtension];
            MovieObject.MovieFilePath = filePath;
            MovieObject.TmpImgName = tempname;

            % Create movie profile
            MovieObject.MovieProfile = QTWriter.createMovieProfile(varargin);

            % Set public properties based on profile
            MovieObject.BitDepth = MovieObject.MovieProfile.ImageBitDepth;
            MovieObject.ColorChannels = ...
                    MovieObject.MovieProfile.ImageColorChannels;
            MovieObject.ColorSpace = MovieObject.MovieProfile.ImageColorSpace;
            MovieObject.CompressionMode = ...
                MovieObject.MovieProfile.ImageCompressionMode;
            MovieObject.CompressionType = ...
                MovieObject.MovieProfile.ImageCompressionType;
            MovieObject.Duration = 0;
            MovieObject.FrameRate = MovieObject.MovieProfile.MovieFrameRate;
            MovieObject.Loop = MovieObject.MovieProfile.MovieLoop;
            MovieObject.MinFramRate = MovieObject.FrameRate;
            MovieObject.MaxFramRate = MovieObject.FrameRate;
            MovieObject.MeanFrameRate = MovieObject.FrameRate;
            MovieObject.PlayAllFrames = ...
                MovieObject.MovieProfile.MoviePlayAllFrames;
            MovieObject.MovieFormat = MovieObject.MovieProfile.MovieFormat;
            MovieObject.Quality = MovieObject.MovieProfile.ImageQuality;
            MovieObject.TimeScale = MovieObject.MovieProfile.MovieTimeScale;
            MovieObject.Transparency = ...
                MovieObject.MovieProfile.ImageTransparency;
        end
        
        function delete(MovieObject)
            %DELETE  Delete a QTWriter object and assosciated files.
            %
            %   DELETE(OBJ) does not need to called directly, as it is called
            %   when the QTWriter object is cleared. If DELETE is called before
            %   CLOSE, the movie will not be saved. 
            %
            %   See also:
            %       QTWriter/close, QTWriter/writeMovie
            
            for i = 1:length(MovieObject)
                % Delete temporary images
                for j = 1:MovieObject(i).FrameCount
                    TmpImageFile = [MovieObject(i).TmpImgName int2str(j)];
                    if exist(TmpImageFile,'file') > 0
                        delete(TmpImageFile);
                    end
                end
                
                % Clear functions and profile
                if isfield(MovieObject(i).MovieProfile,'TmpImageWriteFunction') ...
                        && isa(MovieObject(i).MovieProfile.TmpImageWriteFunction,...
                        'function_handle')
                    clear MovieObject(i).MovieProfile.TmpImageWriteFunction;
                end
                MovieObject(i).MovieProfile = [];
                
                % Delete or close movie file
                if MovieObject(i).MovieFileID == -1
                    % Movie hasn't been saved yet so delete file
                    delete(MovieObject(i).FileName);
                    
                    warning('QTWriter:delete:DeletedBeforeClosing',...
                           ['QTWriter object deleted before closing. Movie '...
                            'file will not be saved.']);
                elseif ~isempty(MovieObject(i).MovieFileID)
                    fclose(MovieObject(i).MovieFileID);
                    
                    if MovieObject(i).FrameCount == 0
                        warning('QTWriter:delete:NoFramesWritten',...
                               ['No movie frames were written to this file. '...
                                'The file may be invalid.']);
                    end
                end
                
                MovieObject(i).IsOpen = false;
            end
        end
        
        function close(MovieObject)
            %CLOSE  Finish writing and close movie file.
            %
            %   CLOSE(OBJ) finishes writing and closes the file associated with
            %   movie writer object OBJ. The movie file will not be playable
            %   until CLOSE is called.
            % 
            %   See also:
            %       QTWriter/writeMovie, QTWriter/delete
            
            for i = 1:length(MovieObject)                
                if ~MovieObject(i).IsOpen
                    continue;
                end
                
                % Open movie file
                [MovieObject(i).MovieFileID,fidMessage] = ...
                    fopen(MovieObject(i).FileName,'wb');
                if MovieObject(i).MovieFileID < 0
                    error('QTWriter:close:CannotCreateFile',...
                         ['Cannot create file %s. The reason given '...
                          'is:\n\n%s'],MovieObject(i).Filename,fidMessage);
                end
                
                % Write header
                fwrite(MovieObject(i).MovieFileID,...
                    MovieObject(i).buildHeader(),'uchar');
                
                % Write frames
                for j = 1:MovieObject(i).FrameCount
                    TmpImageFile = [MovieObject(i).TmpImgName int2str(j)];
                    fid = fopen(TmpImageFile,'r+');
                    if fid < 0
                        error('QTWriter:close:CannotReopenTmpImgFile',...
                              'Could not reopen temporary image file.');
                    end
                    
                    for k = 1:ceil(MovieObject(i).FrameLengths(j)/16384)
                        data = fread(fid,16384,'uchar');
                        fwrite(MovieObject(i).MovieFileID,data,'uchar');
                    end
                    fclose(fid);
                    delete(TmpImageFile);
                end
                
                fclose(MovieObject(i).MovieFileID);
                MovieObject(i).MovieFileID = [];
            end
            
            % Clean up
            delete(MovieObject);
        end
        
        function save(MovieObject)
            %SAVE  Finish writing and close movie file.
            %
            %   SAVE(OBJ) finishes writing and closes the file associated with
            %   movie writer object OBJ. The movie file will not be playable
            %   until SAVE is called.
            % 
            %   See also:
            %       QTWriter/close, QTWriter/writeMovie
            
            close(MovieObject);
        end
        
        function writeMovie(MovieObject,frame)
            %writeMovie  Write movie data to a file.
            %
            %   writeMovie(OBJ,FRAME) writes a FRAME to the movie file
            %   associated with OBJ. FRAME is a structure typically returned by
            %   the GETFRAME function that contains two fields: data and
            %   colormap. If cdata is two-dimensional (height-by-width),
            %   writeMovie constructs RGB image frames using the colormap field.
            %   Otherwise, writeMovie ignores the colormap field. The height and
            %   width must be consistent for all frames within a file.
            %
            %   writeMovie(OBJ,MOV) writes a MATLAB movie MOV to a movie file
            %   MOV is an array of FRAME structures, each of which contains
            %   fields cdata and colormap.
            % 
            %   writeMovie(OBJ,IMAGE) writes data from IMAGE to a movie file.
            %   IMAGE is an array of single, double, or uint8 values
            %   representing grayscale or RGB color images, which writeMovie
            %   writes as an RGB frame. For grayscale data, image is
            %   two-dimensional: height-by-width. For color data, image is
            %   three-dimensional: height-by-width-by-colorchannels. The height
            %   and width must be consistent for all frames within a file. Data
            %   of type single or double must be in the range [0,1].
            %
            %   writeMovie(OBJ,IMAGES) writes a sequence of color images to
            %   a movie file. IMAGES is a four-dimensional array of grayscale
            %   (height-by-width-by-1-by-frames) or RGB
            %   (height-by-width-by-colorchannels-by-frames) images.
            %
            %   See also:
            %       QTWriter/close, QTWriter/delete
            
            if nargin < 2
                error('QTWriter:writeMovie:TooFewInputs',...
                      'Not enough input arguments.');
            end
            if nargin > 2
                error('QTWriter:writeMovie:TooManyInputs',...
                      'Too many input arguments.');
            end
            
            if length(MovieObject) > 1 || ~isa(MovieObject,'QTWriter')
                error('QTWriter:writeMovie:InvalidMovieObject',...
                      'MovieObject must be a 1x1 QTWriter object.');
            end
            
            if ~MovieObject.IsOpen
                MovieObject.IsOpen = true;
            end
            
            if MovieObject.FrameCount == 0
                [MovieObject.Height,MovieObject.Width] = ...
                    QTWriter.getFrameSize(frame);
                MovieObject.MinFramRate = Inf;
                MovieObject.MaxFramRate = 0;
            else
                [frameHeight,frameWidth] = QTWriter.getFrameSize(frame);
                if frameHeight ~= MovieObject.Height || ...
                        frameWidth ~= MovieObject.Width
                    error('QTWriter:writeMovie:BadFrameSize',...
                          'Frame must be %d by %d.',MovieObject.Width,...
                          MovieObject.Height);
                end
            end
            
            if isstruct(frame)
                frame = frame2im(frame);
            end
            MovieObject.writeFrames(frame);
        end
        
    end
    
    % ==========================================================================
    
    methods (Access=private)
        
        function writeFrames(MovieObject,frames)
            dataType = class(frames);
            prefDataType = MovieObject.MovieProfile.PreferredDataType;
            allowedDataTypes = {'single','double'};
            if ~any(strcmp(prefDataType{1},allowedDataTypes))
                allowedDataTypes = [prefDataType{1} allowedDataTypes];
            end
            
            if any(strcmp(prefDataType{1},{'uint16','int16'}))
                allowedDataTypes = [allowedDataTypes {'uint8','int8'}];
            end
            
            if ~any(strcmp(dataType,allowedDataTypes))
                allTypes = [sprintf('%s,',...
                    allowedDataTypes{1:end-1}) allowedDataTypes{end}];
                error('QTWriter:writeFrames:InvalidImgClass',...
                      'IMG must be of one of the following classes: %s',...
                      allTypes);
            end
            
            if ndims(frames) > 4
                error('QTWriter:writeFrames:InvalidImgArray',...
                     ['IMG must be an array of either grayscale or RGB '...
                      'images.']);
            end
            
            colorspace = MovieObject.ColorSpace;
            transparency = MovieObject.Transparency;
            framerate = QTWriter.checkFrameRate(MovieObject.FrameRate);
            for i = 1:size(frames,4)
                frame = QTWriter.convertDataType(prefDataType,frames(:,:,:,i));
                frame = QTWriter.convertColorspace(colorspace,transparency,...
                    frame);
                
                MovieObject.FrameCount = MovieObject.FrameCount+1;
                MovieObject.FrameRates = [MovieObject.FrameRates framerate];
                timescaleexpansion = ...
                    MovieObject.TimeScale./MovieObject.FrameRates;
                timescaleexpansion(timescaleexpansion == Inf) = 0;
                MovieObject.Duration = ...
                    sum(ceil(timescaleexpansion))/MovieObject.TimeScale;
                MovieObject.MinFramRate = ...
                    min(MovieObject.MinFramRate,framerate);
                MovieObject.MaxFramRate = ...
                    max(MovieObject.MaxFramRate,framerate);
                MovieObject.MeanFrameRate = ...
                    MovieObject.MeanFrameRate+(framerate-...
                    MovieObject.MeanFrameRate)/MovieObject.FrameCount;
                TmpImageFile = [MovieObject.TmpImgName ...
                    int2str(MovieObject.FrameCount)];
                MovieObject.MovieProfile.TmpImageWriteFunction(frame,...
                    TmpImageFile);
                
                fid = fopen(TmpImageFile,'r+');
                if fid < 0
                    error('QTWriter:writeFrames:CannotReopenTmpImgFile',...
                          'Could not reopen temporary image file.');
                end
                fseek(fid,0,'eof');
                MovieObject.FrameLengths(MovieObject.FrameCount) = ...
                    ftell(fid);
                
                fclose(fid);
            end
        end
        
        function y=buildHeader(MovieObject)
            imageformatname = MovieObject.MovieProfile.ImageFormatName;
            imagequality = MovieObject.Quality;
            framewidth = MovieObject.Width;
            frameheight = MovieObject.Height;
            movieformatname = MovieObject.MovieProfile.MovieFormatName;
            bitdepth = MovieObject.BitDepth;
            colorspace = MovieObject.ColorSpace;
            framecount = MovieObject.FrameCount;
            framerates = MovieObject.FrameRates;
            timescale = QTWriter.checkTimeScale(MovieObject.TimeScale);
            timescaleexpansion = timescale./framerates;
            timescaleexpansion(timescaleexpansion == Inf) = 0;
            sampleduration = ceil(timescaleexpansion);
            framelengths = MovieObject.FrameLengths;
            framestarts = [0 cumsum(MovieObject.FrameLengths(1:end-1))];
            time = round(3600*24*now);
            transparency = MovieObject.Transparency;
            duration = sum(sampleduration);
            preload = false;
            
            movieloop = QTWriter.checkLoop(MovieObject.Loop);
            movieplayallframes = ...
            	QTWriter.checkPlayAllFrames(MovieObject.PlayAllFrames);
            
            % Build individual atoms and get lengths in bytes
            [stsd_a,stsd_len] = QTWriter.stsd_atom(imageformatname,...
                imagequality,framewidth,frameheight,movieformatname,bitdepth,...
                colorspace,transparency);
            [stts_a,stts_len] = QTWriter.stts_atom(framecount,sampleduration);
            [stsc_a,stsc_len] = QTWriter.stsc_atom();
            [stsz_a,stsz_len] = QTWriter.stsz_atom(framecount,framelengths);
            [stco_a,stco_len] = QTWriter.stco_atom(framestarts);
            
            atomstr_len = 8;    % Length of atom names, e.g., 'moov', in bytes
            
            % Calculate length of 'stbl' atom in bytes
            stbl_len = stsd_len+stts_len+stsc_len+stsz_len+stco_len+atomstr_len;
            
            [vmhd_a,vmhd_len] = QTWriter.vmhd_atom(transparency);
            [hdlr_a2,hdlr_len2] = QTWriter.hdlr_atom('dhlr','alis',...
                'Apple Alias Data Handler');
            [dinf_a,dinf_len] = QTWriter.dinf_atom();
            
            % Calculate length of 'minf' atom in bytes
            minf_len = vmhd_len+hdlr_len2+dinf_len+stbl_len+atomstr_len;
            
            [mdhd_a,mdhd_len] = QTWriter.mdhd_atom(time,timescale,duration);
            [hdlr_a1,hdlr_len1] = QTWriter.hdlr_atom('mhlr','vide',...
                'Apple Video Media Handler');
            
            % Calculate length of 'mdia' atom in bytes
            mdia_len = mdhd_len+hdlr_len1+minf_len+atomstr_len;
            
            [tkhd_a,tkhd_len] = QTWriter.tkhd_atom(time,duration,framewidth,...
                frameheight);
            [tapt_a,tapt_len] = QTWriter.tapt_atom(framewidth,frameheight);
            [edts_a,edts_len] = QTWriter.edts_atom(duration);
            [load_a,load_len] = QTWriter.load_atom(preload);
            
            % Calculate length of 'trak' atom in bytes
            trak_len = tkhd_len+tapt_len+edts_len+load_len+mdia_len+atomstr_len;
            
            [mvhd_a,mvhd_len] = QTWriter.mvhd_atom(time,timescale,duration);
            [wide_a,wide_len] = QTWriter.wide_atom();
            [udta_a,udta_len] = QTWriter.udta_atom(movieloop,...
                movieplayallframes);
            
            % Calculate length of 'moov' atom in bytes
            moov_len = mvhd_len+trak_len+wide_len+udta_len+atomstr_len;
            
            [ftyp_a,ftyp_len] = QTWriter.ftyp_atom();
            
            % Recalculate start of each frame now that header lengths known
            framestarts = framestarts+ftyp_len+moov_len+wide_len+atomstr_len;
            
            % Header
            y =    [ftyp_a ...
                    QTWriter.Bit32(moov_len) double('moov') ...               	% Atom Header
                        mvhd_a ...
                        QTWriter.Bit32(trak_len) double('trak') ...            	% Atom Header
                            tkhd_a ...
                            tapt_a ...
                            edts_a ...
                            load_a ...
                            QTWriter.Bit32(mdia_len) double('mdia') ...        	% Atom Header
                                mdhd_a ...
                                hdlr_a1 ...
                                QTWriter.Bit32(minf_len) double('minf') ...   	% Atom Header
                                    vmhd_a ...
                                    hdlr_a2 ...
                                    dinf_a ...
                                    QTWriter.Bit32(stbl_len) double('stbl') ...	% Atom Header
                                        stsd_a ...
                                        stts_a ...
                                        stsc_a ...
                                        stsz_a ...
                                        QTWriter.stco_atom(framestarts) ...     Re-build with actual framestarts
                        wide_a ...     
                        udta_a ...
                    wide_a ...
                    QTWriter.mdat_atom(framelengths)];                          % Atom Header
        end
        
        function y=buildMiniHeader(MovieObject)
            y =	[QTWriter.ftyp_atom() ...
              	 QTWriter.wide_atom() ...
               	 QTWriter.mdat_atom(MovieObject.FrameLengths)];
        end
        
        function y=buildFooter(MovieObject)
            imageformatname = MovieObject.MovieProfile.ImageFormatName;
            imagequality = MovieObject.Quality;
            framewidth = MovieObject.Width;
            frameheight = MovieObject.Height;
            movieformatname = MovieObject.MovieProfile.MovieFormatName;
            bitdepth = MovieObject.BitDepth;
            colorspace = MovieObject.ColorSpace;
            framecount = MovieObject.FrameCount;
            framerates = MovieObject.FrameRates;
            timescale = QTWriter.checkTimeScale(MovieObject.TimeScale);
            timescaleexpansion = timescale./framerates;
            timescaleexpansion(timescaleexpansion == Inf) = 0;
            sampleduration = ceil(timescaleexpansion);
            framelengths = MovieObject.FrameLengths;
            framestarts = [0 cumsum(MovieObject.FrameLengths(1:end-1))];
            time = round(3600*24*now);
            transparency = MovieObject.Transparency;
            duration = sum(sampleduration);
            preload = false;
            
            movieloop = QTWriter.checkLoop(MovieObject.Loop);
            movieplayallframes = ...
                QTWriter.checkPlayAllFrames(MovieObject.PlayAllFrames);
            
            atomstr_len = 8;    % Length of atom names, e.g., 'moov', in bytes
            
            [ftyp_a,ftyp_len] = QTWriter.ftyp_atom();
            [wide_a,wide_len] = QTWriter.wide_atom();
            framestarts = framestarts+ftyp_len+wide_len+atomstr_len;
            
            % Build individual atoms and get lengths in bytes
            [stsd_a,stsd_len] = QTWriter.stsd_atom(imageformatname,...
                imagequality,framewidth,frameheight,movieformatname,bitdepth,...
                colorspace,transparency);
            [stts_a,stts_len] = QTWriter.stts_atom(framecount,sampleduration);
            [stsc_a,stsc_len] = QTWriter.stsc_atom();
            [stsz_a,stsz_len] = QTWriter.stsz_atom(framecount,framelengths);
            [stco_a,stco_len] = QTWriter.stco_atom(framestarts);
            
            % Calculate length of 'stbl' atom in bytes
            stbl_len = stsd_len+stts_len+stsc_len+stsz_len+stco_len+atomstr_len;
            
            [vmhd_a,vmhd_len] = QTWriter.vmhd_atom(transparency);
            [hdlr_a2,hdlr_len2] = QTWriter.hdlr_atom('dhlr','alis',...
                'Apple Alias Data Handler');
            [dinf_a,dinf_len] = QTWriter.dinf_atom();
            
            % Calculate length of 'minf' atom in bytes
            minf_len = vmhd_len+hdlr_len2+dinf_len+stbl_len+atomstr_len;
            
            [mdhd_a,mdhd_len] = QTWriter.mdhd_atom(time,timescale,duration);
            [hdlr_a1,hdlr_len1] = QTWriter.hdlr_atom('mhlr','vide',...
                'Apple Video Media Handler');
            
            % Calculate length of 'mdia' atom in bytes
            mdia_len = mdhd_len+hdlr_len1+minf_len+8;
            
            [tkhd_a,tkhd_len] = QTWriter.tkhd_atom(time,duration,framewidth,...
                frameheight);
            [tapt_a,tapt_len] = QTWriter.tapt_atom(framewidth,frameheight);
            [edts_a,edts_len] = QTWriter.edts_atom(duration);
            [load_a,load_len] = QTWriter.load_atom(preload);
            
            % Calculate length of 'trak' atom in bytes
            trak_len = tkhd_len+tapt_len+edts_len+load_len+mdia_len+atomstr_len;
            
            [mvhd_a,mvhd_len] = QTWriter.mvhd_atom(time,timescale,duration);
            [udta_a,udta_len] = QTWriter.udta_atom(movieloop,...
                movieplayallframes);
            
            % Calculate length of 'moov' atom in bytes
            moov_len = mvhd_len+trak_len+wide_len+udta_len+atomstr_len;
            
            % Footer
            y =	[QTWriter.Bit32(moov_len) double('moov') ...               	% Atom Header
                    mvhd_a ...
                    QTWriter.Bit32(trak_len) double('trak') ...            	% Atom Header
                        tkhd_a ...
                        tapt_a ...
                        edts_a ...
                        load_a ...
                        QTWriter.Bit32(mdia_len) double('mdia') ...        	% Atom Header
                            mdhd_a ...
                            hdlr_a1 ...
                            QTWriter.Bit32(minf_len) double('minf') ...   	% Atom Header
                                vmhd_a ...
                                hdlr_a2 ...
                                dinf_a ...
                                QTWriter.Bit32(stbl_len) double('stbl') ...	% Atom Header
                                    stsd_a ...
                                    stts_a ...
                                    stsc_a ...
                                    stsz_a ...
                                    stco_a ...
                    wide_a ...
                    udta_a];
        end
        
    end
    
    % ==========================================================================
    
    methods (Static)
        
        function install(opt)
            %INSTALL  Add or remove QTWriter from Matlab search path.
            %
            %   QTWriter.install() adds the QTWriter directory (where this class
            %   function is located) to the Matlab search path and saves the
            %   path.
            %
            %   QTWriter.install('remove') uninstalls QTWriter by removing the
            %   QTWriter directory from the Matlab search path and saving the
            %   path. If QTWriter is not installed (on the path), a warning is
            %   issued.
            %
            %   See also:
            %       PATH, ADDPATH, RMPATH, SAVEPATH
            
            if nargin < 1 || any(strcmp(opt,{'add','install','addpath'}))
                addpath(fileparts(mfilename('fullpath')));
                status = true;
            elseif any(strcmp(opt,{'remove','uninstall','rmpath'}))
                rmpath(fileparts(mfilename('fullpath')));
                status = false;
            else
                error('QTWriter:install:UnknownOption',...
                     ['Input argument must be the string ''install'' to '...
                      'install or ''remove'' to uninstall.']);
            end
            
            if savepath
                error('QTWriter:install:SavePathError',...
                      'Unable to save pathdef.m file.');
            end
            rehash('toolbox');
            clear('QTWriter');
            
            if status
                fprintf(1,'\n QTWriter installed.\n\n');
            else
                fprintf(1,'\n QTWriter uninstalled.\n');
            end
        end
        
    end
    
    % ==========================================================================

    methods (Static,Access=private)
        
        function framerate=checkFrameRate(framerate)
            if isempty(framerate)
                framerate = 20;
            else
                if ~isscalar(framerate) || ~isreal(framerate) || ...
                        ~isnumeric(framerate) || ~isfinite(framerate) || ...
                        framerate < 0
                    error('QTWriter:checkFrameRate:InvalidFrameRate',...
                         ['The FrameRate property, if specified, must be a ' ...
                          'finite real scalar value greater than or equal '...
                          'to 0.']);
                end
            end
        end
        
        function loop=checkLoop(loop)
            if isempty(loop)
                loop = 'none';
            else
                if ischar(loop)
                    if any(strcmpi(loop,{'none','no','off','false'}))
                        loop = 'none';
                    elseif any(strcmpi(loop,{'loop','looping','yes','on',...
                            'true'}))
                        loop = 'loop';
                    elseif any(strcmpi(loop,{'backandforth','palindromic'}))
                        loop = 'backandforth';
                    else
                        error('QTWriter:checkLoop:InvalidLoop',...
                             ['The Loop property, if specified, must be ' ...
                               '''on'', ''off'', or ''backandforth''.']);
                    end
                elseif ~isscalar(loop) || ~isreal(loop) || ...
                        ~isnumeric(loop) || ~any(loop == [-1 0 1])
                    error('QTWriter:checkLoop:InvalidLoopValue',...
                      	 ['The Loop property if specified as an integer ' ...
                          'must be -1, 0, or 1.']);
                end
            end
        end
        
        function parameters = checkMoviePropertyNames(properties)
            validPropertyNames = {	'BitDepth',...
                                    'ColorSpace',...
                                    'CompressionMode',...
                                    'CompressionType',...
                                    'FrameRate',...
                                    'Loop',...
                                    'MovieFormat',...
                                    'PlayAllFrames',...
                                    'Quality',...
                                    'TimeScale',...
                                    'Transparency'};
            
            m = length(validPropertyNames);
            parameters = cell2struct(cell(m,1),validPropertyNames,1);
            if ~isempty(properties)
                n = length(properties);
                if n == 1 && ~isempty(properties{1}) && ...
                        isa(properties{1},'struct')
                    for j = 1:m
                        Name = validPropertyNames{j};
                        if any(strcmp(fieldnames(properties{1}),Name))
                            parameters.(Name) = properties{1}.(Name);
                        end
                    end
                else
                    i = 1;
                    if n == 1 && ~isempty(properties{1}) && ...
                            iscell(properties{1})
                        properties = properties{:};
                        n = length(properties);
                    end
                    if mod(n,2)
                        error('QTWriter:checkMoviePropertyNames:UnmatchedProperty',...
                              'Properties must occur in name-value pairs.');
                    end
                    while i <= n
                        arg = properties{i};
                        if ~ischar(arg)
                            error('QTWriter:checkMoviePropertyNames:NonStringPropertyName',...
                                 ['Expected argument %d to be a string ' ...
                                  'property name.'],i+1);
                        end
                        j = strncmpi(arg,validPropertyNames,length(arg));
                        if ~any(j)
                            error('QTWriter:checkMoviePropertyNames:UnrecognizedPropertyName',...
                                  'Unrecognized property name ''%s''.',arg);
                        elseif nnz(j) > 1
                            j = strcmpi(arg,validPropertyNames);
                            if ~any(j)
                                msg = cell2mat(strcat({', '},...
                                    validPropertyNames(j))');
                                error('QTWriter:checkMoviePropertyNames:AmbiguousPropertyName',...
                                     ['Ambiguous property name ' ...
                                       'abbreviation''%s'' (' msg(3:end) ...
                                       ').'],arg);
                            end
                        end
                        parameters.(validPropertyNames{j}) = properties{i+1};
                        i = i+2;
                    end
                end
            end
        end
        
        function playallframes=checkPlayAllFrames(playallframes)
            if isempty(playallframes)
                playallframes = false;
            else
                if ~islogical(playallframes)
                    error('QTWriter:checkPlayAllFrames:InvalidPlayAllFrames',...
                         ['The PlayAllFrames property, if specified, must ' ...
                          'be a logical value (true or false).']);
                end
            end
        end
        
        function timescale=checkTimeScale(timescale)
            if isempty(timescale)
                timescale = 1e4;
            else
                if ~isscalar(timescale) || ~isreal(timescale) || ...
                        ~isnumeric(timescale) || ~isfinite(timescale) || ...
                        timescale <= 0 || timescale-floor(timescale) ~= 0
                    error('QTWriter:checkTimeScale:InvalidTimeScale',...
                         ['The TimeScale property, if specified, must be a ' ...
                          'finite real integer > 0.']);
                end
            end
        end
        
        function frame = convertColorspace(colorspace,transparency,frame)
            if ndims(frame) == 2   %#ok<*ISMAT>
                colorchannels = 1;
            elseif any(size(frame,3) == [1 3 4])
                colorchannels = size(frame,3);
            else
                error('QTWriter:convertColorspace:InvalidImgArray',...
                     ['IMG must be an array of either grayscale images or '...
                      'RGB images with or without alpha channel.']);
            end

            switch colorspace
                case 'rgb'
                    if colorchannels == 1
                        frame = repmat(frame,[1 1 3 1]);
                    end
                    if transparency && colorchannels ~= 4
                        frame(:,:,4,:) = ...
                            zeros(size(frame,1),size(frame,2),1,1)+255;
                    end
                case 'grayscale'
                    if transparency
                        if colorchannels == 1
                            frame = repmat(frame,[1 1 3 1]);
                            frame(:,:,4,:) = zeros(size(frame,1),...
                                size(frame,2),1,1)+255;
                        elseif colorchannels == 3
                            frame = rgb2gray(frame);
                            frame = repmat(frame,[1 1 3 1]);
                            frame(:,:,4,:) = zeros(size(frame,1),...
                                size(frame,2),1,1)+255;
                        else
                            frame(:,:,1,:) = rgb2gray(frame(:,:,1:3,:));
                            frame(:,:,2,:) = frame(:,:,1,:);
                            frame(:,:,3,:) = frame(:,:,1,:);
                        end
                    else
                        if colorchannels == 3
                            frame = rgb2gray(frame);
                        end
                    end
                otherwise
                    warning('QTWriter:convertColorspace:UnknownColorFormat',...
                            'Unknown color format for this profile.');
            end
        end
        
        function outFrame = convertDataType(prefDataType,frame)
            curDataType = class(frame);

            if any(strcmp(curDataType,prefDataType))
                outFrame = frame;
                return;
            end

            isFloat = any(strcmp(curDataType,{'single','double'}));
            if isFloat
                if min(frame(:)) < 0 || max(frame(:)) > 1
                    error('QTWriter:convertDataType:FloatRange',...
                          'Frames of type %s must be in the range 0 to 1.',...
                          curDataType);
                end
            end
            
            if length(prefDataType) ~= 1
                error('QTWriter:convertDataType:PrefDataType',...
                     ['Unable to convert from type %s since the preferred '...
                      'data type is not yet known.'],curDataType);
            end
            
            if any(strcmp(curDataType,{'single','double'}))
                minval = double(intmin(prefDataType{1}));
                maxval = double(intmax(prefDataType{1}));
                outFrame = cast(frames.*(maxval-minval)-minval,prefDataType{1});
                return
            end
            
            try
                outFrame = QTWriter.convertFrameDataType(prefDataType{1},...
                    curDataType,frame);
            catch err
                error('QTWriter:convertDataType:CastError',...
                     ['The requested conversion of %s to %s is not '...
                      'supported by writeMovie.'],curDataType,prefDataType{1});
            end
        end

        function outFrame=convertFrameDataType(outType,inType,frame)
            largerRange = double(intmax(outType))-double(intmin(outType))+1;
            smallerRange = double(intmax(inType))-double(intmin(inType))+1;
            mult = largerRange/smallerRange;
            b = double(intmin(outType))-double(intmin(inType))*mult;
            outFrame = cast(double(frame)*mult+b,outType);
        end
        
        function movieProfile=createMovieProfile(properties)
            movieProfile = struct;
            parameters = QTWriter.checkMoviePropertyNames(properties);
            
            if isempty(parameters.MovieFormat)
                movieProfile.MovieFormat = 'default';
            else
                movieProfile.MovieFormat = lower(parameters.MovieFormat);
            end
            
            % Resolve movie format
            switch movieProfile.MovieFormat
                case lower({'default','PNG','Photo PNG','Photo-PNG',...
                        'PhotoPNG','Apple Photo - PNG','Apple Photo PNG',...
                        'Apple PNG'})
                    movieProfile.MovieImageFormat = 'png';
                    movieProfile.ImageFormatName = 'png ';
                    movieProfile.MovieFormat = 'Photo PNG';
                    movieProfile.MovieFormatName = 'PNG';
                case lower({'Photo JPEG','Photo-JPEG','Photo - JPEG','JPEG',...
                        'JPG','PhotoJPEG','Apple Photo - JPEG',...
                        'Apple Photo JPEG'})
                    movieProfile.MovieImageFormat = 'jpg';
                    movieProfile.ImageFormatName = 'jpeg';
                    movieProfile.MovieFormat = 'Photo JPEG';
                    movieProfile.MovieFormatName = 'Photo - JPEG';
                case lower({'TIFF','Photo TIFF','TIF','Photo-TIFF',...
                        'PhotoTIFF','Apple Photo - TIFF','Apple Photo TIFF',...
                        'Apple TIFF'})
                    movieProfile.MovieImageFormat = 'tif';
                    movieProfile.ImageFormatName = 'tiff';
                    movieProfile.MovieFormat = 'Photo TIFF';
                    movieProfile.MovieFormatName = 'TIFF';
                otherwise
                    error('QTWriter:createMovieProfile:InvalidMovieFormat',...
                         ['An unknown MovieFormat, ''%s'', was specified. '...
                          'Valid movie formats are: ''Photo PNG'' '...
                          '(default), ''Photo JPEG'', and ''Photo TIFF''.'],...
                          parameters.MovieFormat);
            end
            
            % Structure containing image write function handle
            ImageFormat = imformats(movieProfile.MovieImageFormat);
            
            % Reslove propert values
            switch movieProfile.MovieImageFormat
                case 'png'
                    % Set Transparency
                    if isempty(parameters.Transparency)
                         movieProfile.ImageTransparency = false;
                    else
                        if ~islogical(parameters.Transparency)
                            error('QTWriter:createMovieProfile:InvalidTransparencyPNG',...
                                 ['The Transparency property, if ' ...
                                  'specified, must be a logical value (true '...
                                  'or false).']);
                        else
                            movieProfile.ImageTransparency = ...
                                parameters.Transparency;
                        end
                    end
                    
                    % Set Compression Mode
                    movieProfile.ImageCompressionMode = 'lossless';
                    if ~isempty(parameters.CompressionMode) && ...
                            ~strcmpi(parameters.CompressionMode,'lossless')
                        warning('QTWriter:createMovieProfile:LossyNotSupportedPNG',...
                               ['The CompressionMode property is not ' ...
                                'supported for Photo PNG format movies. PNG '...
                                'is a lossless compression format.']);
                    end
                    
                    % Set Compression Type
                    movieProfile.ImageCompressionType = 'deflate';
                    if ~isempty(parameters.CompressionType) && ...
                            ~any(strcmpi(parameters.CompressionType,{'png',...
                            'deflate','default'}))
                        warning('QTWriter:createMovieProfile:CompressionTypeNotSupportedPNG',...
                               ['The CompressionType property is not ' ...
                                'supported for Photo PNG format movies.']);
                    end
                    
                    % Set Bit Depth
                    movieProfile.ImageBitDepth = 8;
                    if ~isempty(parameters.BitDepth) && ...
                            isscalar(parameters.BitDepth) && ...
                            parameters.BitDepth ~= 8
                        warning('QTWriter:createMovieProfile:BitDepthNotSupportedPNG',...
                               ['The BitDepth property is not supported ' ...
                                'for Photo PNG format movies. All movies '...
                                'have a bit-depth of 8 (8-bit grayscale, '...
                                '24-bit RGB, and 32-bit RGB with '...
                                'transparency).']);
                    end
                    
                    % Set Colorspace  and Color Channels
                    if ~isempty(parameters.ColorSpace)
                        if any(strcmpi(parameters.ColorSpace,...
                                    {'grayscale','monochrome'}))
                            movieProfile.ImageColorSpace = 'grayscale';
                            movieProfile.ImageColorChannels = 1;
                        elseif any(strcmpi(parameters.ColorSpace,...
                                    {'rgb','truecolor','any'}))
                            movieProfile.ImageColorSpace = 'rgb';
                            movieProfile.ImageColorChannels = 3;
                        else
                            error('QTWriter:createMovie:InvalidColorSpacePNG',...
                                 ['The ColorSpace for Photo PNG format '...
                                  'movies, if specified, must be either '...
                                  '''rgb'' or ''grayscale''.']);
                        end
                    else
                        movieProfile.ImageColorSpace = 'rgb';
                        movieProfile.ImageColorChannels = 3;
                    end
                    if movieProfile.ImageTransparency
                        movieProfile.ImageColorChannels = 4;
                    end
                    
                    % Set Quality
                    movieProfile.ImageQuality = 100;
                    if ~isempty(parameters.Quality) && ...
                            isscalar(parameters.Quality) && ...
                            isreal(parameters.Quality) && ...
                            isnumeric(parameters.Quality) && ...
                            parameters.Quality ~= 100
                        warning('QTWriter:createMovieProfile:BitDepthNotSupportedPNG',...
                               ['The Quality property is not supported for ' ...
                                'Photo PNG format movies. PNG is a lossless '...
                                'compression format.']);
                    end
                    
                    % Create function handle
                    if movieProfile.ImageTransparency
                        movieProfile.TmpImageWriteFunction = ...
                            @(frame,filename)feval(ImageFormat.write,...
                            frame(:,:,1:3),[],filename,...
                            'bitdepth',movieProfile.ImageBitDepth,...
                            'alpha',frame(:,:,4));
                    else
                        movieProfile.TmpImageWriteFunction = ...
                            @(frame,filename)feval(ImageFormat.write,...
                            frame(:,:,1:movieProfile.ImageColorChannels),...
                            [],filename,...
                            'bitdepth',movieProfile.ImageBitDepth);
                    end
                case 'jpg'
                    % Set Transparency
                    movieProfile.ImageTransparency = false;
                    if ~isempty(parameters.Transparency) && ...
                            ~any(strcmpi(parameters.Transparency,...
                            {'no','none','off','false'}))
                        warning('QTWriter:createMovieProfile:AlphaNotSupportedJPG',...
                               ['The Transparency property is not ' ...
                                'supported for %s format movies. Any ' ...
                                'provided alpha channel data will be ' ...
                                'ignored.'],movieProfile.MovieFormat);
                    end
                    
                    % Set Compression Mode
                    movieProfile.ImageCompressionMode = 'lossy';
                    if ~isempty(parameters.CompressionMode) && ...
                            ~strcmpi(parameters.CompressionMode,'lossy')
                        warning('QTWriter:createMovieProfile:LosslessNotSupportedJPG',...
                               ['The CompressionMode property is not ' ...
                                'supported for %s format movies. JPEG is a '...
                                'lossy compression format.'],...
                                movieProfile.MovieFormat);
                    end
                    
                    % Set Compression Type
                    movieProfile.ImageCompressionType = 'jpeg';
                    if ~isempty(parameters.CompressionType) && ...
                            ~any(strcmpi(parameters.CompressionType,{'jpg',...
                            'jpeg','default'}))
                        warning('QTWriter:createMovieProfile:CompressionTypeNotSupportedJPG',...
                               ['The CompressionType property is not ' ...
                                'supported for Photo JPEG format movies.']);
                    end
                    
                    % Set Bit Depth
                    movieProfile.ImageBitDepth = 8;
                    if ~isempty(parameters.BitDepth) && ...
                            isscalar(parameters.BitDepth) && ...
                            parameters.BitDepth ~= 8
                        warning('QTWriter:createMovieProfile:BitDepthNotSupportedJPG',...
                               ['The BitDepth property is not supported ' ...
                                'for %s format movies. All movies have a '...
                                'bit-depth of 8 (8-bit grayscale and 24-bit '...
                                'RGB).'],movieProfile.MovieFormat);
                    end
                    
                    % Set Colorspace  and Color Channels
                    if ~isempty(parameters.ColorSpace)
                        if any(strcmpi(parameters.ColorSpace,...
                                    {'grayscale','monochrome'}))
                            movieProfile.ImageColorSpace = 'grayscale';
                            movieProfile.ImageColorChannels = 1;
                        elseif any(strcmpi(parameters.ColorSpace,...
                                    {'rgb','truecolor','any'}))
                            movieProfile.ImageColorSpace = 'rgb';
                            movieProfile.ImageColorChannels = 3;
                        else
                            error('QTWriter:createMovie:InvalidColorSpaceJPG',...
                                 ['The ColorSpace for %s format movies, if '...
                                  'specified, must be either ''rgb'' or '...
                                  '''grayscale''.'],movieProfile.MovieFormat);
                        end
                    else
                        movieProfile.ImageColorSpace = 'rgb';
                        movieProfile.ImageColorChannels = 3;
                    end
                    
                    % Set Quality
                    if isempty(parameters.Quality)
                         movieProfile.ImageQuality = 100;
                    else
                        if ~isscalar(parameters.Quality) || ...
                                ~isreal(parameters.Quality) || ...
                                ~isnumeric(parameters.Quality) || ...
                                isnan(parameters.Quality) || ...
                                parameters.Quality < 0 || ...
                                parameters.Quality > 100
                            error('QTWriter:createMovieProfile:InvalidQualityJPG',...
                                 ['The Quality property, if specified, ' ...
                                  'must be a finite real scalar value >= 0 ' ...
                                  'and <= 100 for %s format movies.'],...
                                  movieProfile.MovieFormat);
                        else
                            movieProfile.ImageQuality = parameters.Quality;
                        end
                    end
                    
                    % Create function handle
                    movieProfile.TmpImageWriteFunction = ...
                        @(frame,filename)feval(ImageFormat.write,...
                     	frame(:,:,1:movieProfile.ImageColorChannels),...
                       	[],filename,...
                       	'quality',movieProfile.ImageQuality,...
                      	'bitdepth',movieProfile.ImageBitDepth);
             	case 'tif'
                    % Set Transparency
                    movieProfile.ImageTransparency = false;
                    if ~isempty(parameters.Transparency) && ...
                            ~any(strcmpi(parameters.Transparency,...
                            {'no','none','off','false'}))
                        warning('QTWriter:createMovieProfile:AlphaNotSupportedTIF',...
                               ['The Transparency property is not ' ...
                                'supported for %s format movies. Any '...
                                'provided alpha channel data will be '...
                                'ignored.'],movieProfile.MovieFormat);
                    end
                    
                    % Set Compression Mode
                    movieProfile.ImageCompressionMode = 'lossless';
                    if ~isempty(parameters.CompressionMode) && ...
                            ~strcmpi(parameters.CompressionMode,'lossless')
                        warning('QTWriter:createMovieProfile:LossyNotSupportedTIF',...
                               ['The CompressionMode property is not ' ...
                                'supported for Photo TIFF format movies. '...
                                'Use the ''CompressionType'' parameter to '...
                                'specify the type of lossless compression.']);
                    end
                    
                    % Set Compression Type
                    ctype = lower(parameters.CompressionType);
                    if isempty(ctype) || any(strcmp(ctype,{'default',....
                            'packbits'}))
                        movieProfile.ImageCompressionType = 'packbits';
                    else
                        if any(strcmp(ctype,{'none','lzw'}))
                            movieProfile.ImageCompressionType = ctype;
                        else
                            error('QTWriter:createMovie:InvalidCompressionType',...
                                 ['The CompressionType for Photo TIFF '...
                                  'format movies, if specified, must be '...
                                  '''packbits'' (default), ''lzw'', or '...
                                  '''none''.']);
                        end
                    end
                    
                    % Set Bit Depth
                    movieProfile.ImageBitDepth = 8;
                    if ~isempty(parameters.BitDepth) && ...
                            isscalar(parameters.BitDepth) && ...
                            parameters.BitDepth ~= 8
                        warning('QTWriter:createMovieProfile:BitDepthNotSupportedTIF',...
                               ['The BitDepth property is not supported ' ...
                                'for Photo TIFF format movies. All movies '...
                                'have a bit-depth of 8 (8-bit grayscale and '...
                                '24-bit RGB).']);
                    end
                    
                    % Set Colorspace  and Color Channels
                    if ~isempty(parameters.ColorSpace)
                        if any(strcmpi(parameters.ColorSpace,...
                                    {'grayscale','monochrome'}))
                            movieProfile.ImageColorSpace = 'grayscale';
                            movieProfile.ImageColorChannels = 1;
                        elseif any(strcmpi(parameters.ColorSpace,...
                                    {'rgb','truecolor','any'}))
                            movieProfile.ImageColorSpace = 'rgb';
                            movieProfile.ImageColorChannels = 3;
                        else
                            error('QTWriter:createMovie:InvalidColorSpaceTIF',...
                                 ['The ColorSpace for Photo TIFF format '...
                                  'movies, if specified, must be either '...
                                  '''rgb'' or ''grayscale''.']);
                        end
                    else
                        movieProfile.ImageColorSpace = 'rgb';
                        movieProfile.ImageColorChannels = 3;
                    end
                    
                    % Set Quality
                    movieProfile.ImageQuality = 100;
                    if ~isempty(parameters.Quality) && ...
                            isscalar(parameters.Quality) && ...
                            isreal(parameters.Quality) && ...
                            isnumeric(parameters.Quality) && ...
                            parameters.Quality ~= 100
                        warning('QTWriter:createMovieProfile:BitDepthNotSupportedTIF',...
                               ['The Quality property is not supported for ' ...
                                'Photo TIFF format movies. Lossless packbit '...
                                'compression is used for the TIFF format.']);
                    end
                    
                    % Create function handle
                    movieProfile.TmpImageWriteFunction = ...
                        @(frame,filename)feval(ImageFormat.write,...
                        frame(:,:,1:movieProfile.ImageColorChannels),...
                        [],filename,...
                        'compression',movieProfile.ImageCompressionType);
                otherwise
                    error('QTWriter:createMovieProfile:InvalidMovieFormat',...
                         ['An unknown MovieFormat, ''%s'', was specified. '...
                          'Valid movie formats are: ''Photo PNG'', '...
                          '''Photo JPEG'', and ''Photo TIFF''.'],...
                          parameters.MovieFormat);
            end
            
            movieProfile.PreferredDataType = {'uint8'};
            
            % Set Frame-rate
            movieProfile.MovieFrameRate = ...
                QTWriter.checkFrameRate(parameters.FrameRate);
            
            % Set Time-scale
            movieProfile.MovieTimeScale = ...
                QTWriter.checkTimeScale(parameters.TimeScale);
            
            % Set Loop
            movieProfile.MovieLoop = QTWriter.checkLoop(parameters.Loop);
            
            % Set Play All Frames
            movieProfile.MoviePlayAllFrames = ...
                QTWriter.checkPlayAllFrames(parameters.PlayAllFrames);
        end
        
        function [height,width]=getFrameSize(frame)
            if isstruct(frame)
                height = size(frame(1).cdata,1);
                width = size(frame(1).cdata,2);
            else
                height = size(frame,1);
                width = size(frame,2);
            end
        end
        
        function filename=validatefile(filename)
            if isempty(filename) || ~ischar(filename)
                error('QTWriter:validatefile:EmptyFileString',...
                      'The file name must be a non-empty string.');
            end
            
            % Check if file can be opened to read/write, create if doesn't exist
            [fid,fidMessage] = fopen(filename,'a+');
            if fid == -1
                error('QTWriter:validatefile:FileOpenError',...
                      'Unable to open file ''%s'':\n\n%s',filename,fidMessage);
            end
            fclose(fid);
            
            [success,info] = fileattrib(filename);	%#ok<*ASGLU>
            if usejava('jvm')
                filename = char(java.io.File(info.Name).getCanonicalPath());
            else
                filename = info.Name;
            end
        end
        
        function filename=validatefilepath(filename,extensions)
            if isempty(filename) || ~ischar(filename)
                error('QTWriter:validatefilepath:EmptyFileString',...
                      'The file name must be a non-empty string.');
            end
            
            % Convert file separators if necessary and split into parts
            filename = regexprep(filename,'[\/\\]',filesep);
            [pathString,baseFile,extensionProvided] = fileparts(filename);
            
            % Check that path to file exists
            if isempty(pathString)
                pathString = pwd;
            elseif exist(pathString,'dir') ~= 7
                error('QTWriter:validatefilepath:InvalidFilePath',...
                      'The specified directory, ''%s'', does not exist.',...
                      pathString);
            end
            
            % Check that extension(s) are valid, remove leading period if needed
            if nargin == 2
                if ~ischar(extensions)
                    if isempty(extensions) || ~iscell(extensions)
                        error('QTWriter:validatefilepath:InvalidExtension',...
                             ['The optional extensions argument must be '...
                              'string or a non-empty cell array of strings.']);
                    end
                    
                    if isempty(extensionProvided)
                        extensionProvided = extensions{1};
                    else
                        % Go through cell array and remove any leading periods
                        for i = 1:length(extensions)
                            if isempty(extensions{i}) || ~ischar(extensions{i})
                                error('QTWriter:validatefilepath:InvalidExtensionList',...
                                     ['The optional extensions argument is '...
                                      'a cell array, but one or more of its '...
                                      'elements is empty or not a string.']);
                            end
                            extensions{i} = regexprep(extensions{i},'^(\.)','');
                        end
                        
                        % Compare file name extension to those in extensions
                        if ~any(strcmpi(extensionProvided(2:end),extensions))
                            apos = {''''};
                            period = {'.'};
                            comma = {','};
                            sp = {' '};
                            v = ones(1,length(extensions));
                            validExtensions = [apos(v);period(v);...
                                               extensions(:)';apos(v);...
                                               comma(v);sp(v)];
                            validExtensions = cell2mat(validExtensions(:)');
                            error('QTWriter:validatefilepath:InvalidFileExtensions',...
                                 ['File name must have one of the following ',...
                                  'extensions: %s.'],validExtensions(1:end-2));
                        end
                    end
                else
                    if isempty(extensions)
                        error('QTWriter:validatefilepath:EmptyFileExtension',...
                             ['The optional extensions argument must be '...
                              'non-empty string or non-empty cell array of '...
                              'strings.']);
                    end
                    
                    if isempty(extensionProvided)
                        extensionProvided = extensions;
                    else
                        extensions = regexprep(extensions,'^(\.)','');
                        if ~strcmpi(extensionProvided(2:end),extensions)
                            error('QTWriter:validatefilepath:InvalidFileExtension',...
                                  'File name must have a ''.%s'' extension.',...
                                  extensions);
                        end
                    end
                end
            end

            filename = fullfile(pathString,[baseFile extensionProvided]);
        end
        
        function y=Bit32(x)
            y = [bitshift(x,-24); ...
                 bitshift(x,-16); ...
                 bitshift(x, -8); ...
                 x];
            y = bitand(y(:)',255);
        end
        
        function [atom,len]=ctab_atom(table)
            n = size(table,1);
            nn = QTWriter.Bit32(n-1);
            table =table';
            z = zeros(2,n);
            red = zeros(4,n);
            blue = zeros(4,n);
            green = zeros(4,n);
            red(:) = QTWriter.Bit32(table(1,:));
            blue(:) = QTWriter.Bit32(table(2,:));
            green(:) = QTWriter.Bit32(table(3,:));
            ctab = [z;red(3:4,:);green(3:4,:);blue(3:4,:)];
            len = 8*n+22;
            atom = [QTWriter.Bit32(len) double('ctab') ...  % Atom Header
                        0 0 0 0 ...                         % Type
                        0 0 0 0 ...                         % Color table seed
                        0 0 0 8 ...                         % Color table flags
                        nn(3:4) ...                         % Color table size
                        ctab(:)'];                          % Color array
        end
        
        function [atom,len]=dinf_atom()
            atom = [0 0 0 36 double('dinf') ...         % Atom Header
                        ...
                        0 0 0 28 double('dref') ...
                            0 0 0 0 ...                 % Version, Flags
                            0 0 0 1 ...                 % Number of entries
                            ...
                            0 0 0 12 double('alis') ...
                                0 0 0 1];               % Version, Flags
            len = 36;
        end
        
        function [atom,len]=edts_atom(duration)
            atom = [0 0 0 36 double('edts') ...             % Atom Header
                        ...
                        0 0 0 28 double('elst') ...         % Atom Header
                            0 0 0 0 ...                     % Version, Flags
                            0 0 0 1 ...                     % Number of entries
                            QTWriter.Bit32(duration) ...	% Edit list table: Track duration
                            0 0 0 0 ...                     % Edit list table: Media time
                            0 1 0 0];                       % Edit list table: Media rate
            len = 36;
        end
        
        function [atom,len]=free_atom()
             atom = [0 0 0 8 double('free')];   % Atom Header
             len = 8;
        end
        
        function [atom,len]=ftyp_atom()
            atom = [0 0 0 24 double('ftyp') ...	% Atom Header
                        double('qt  ') ...  	% Major_Brand
                        32 5 3 0 ...           	% Minor_Version
                        double('qt  ') ...    	% Compatible_Brands
                        0 0 0 0];
            len = 24;
        end
        
        function [atom,len]=hdlr_atom(type,subtype,name)
            n = length(name);
            len = n+33;
            atom = [QTWriter.Bit32(len) double('hdlr') ...	% Atom Header
                        0 0 0 0 ...                         % Version, Flags
                        double(type) ...                    % Component type
                        double(subtype) ...                 % Component subtype
                        0 0 0 0 ...                         % Component manufacturer
                        0 0 0 0 ...                     	% Component flags
                        0 0 0 0 ...                         % Component flags mask
                        n ...                               % Component name byte count
                        double(name)];                      % Component name
        end
        
        function [atom,len]=load_atom(preload)
            if preload
                duration = [255 255 255 255];   % All frames
            else
                duration = [0 0 0 0];           % None
            end
            atom = [0 0 0 24 double('load') ...	% Atom Header
                        0 0 0 0 ...           	% Preload start time
                        duration ...            % Preload duration
                        0 0 0 0 ...           	% Preload flags
                        0 0 1 0];             	% Default hints (High Quality)
            len = 24;
        end
        
        function [atom,len]=mdat_atom(framelengths)
            len = sum(framelengths)+8;
            atom = [QTWriter.Bit32(len) double('mdat')];	% Atom Header
        end
        
        function [atom,len]=mdhd_atom(time,timescale,duration)
            atom = [0 0 0 32 double('mdhd') ...         % Atom Header
                        0 0 0 0 ...                     % Version, Flags
                        QTWriter.Bit32(time) ...       	% Creation time
                        QTWriter.Bit32(time) ...       	% Modification time
                        QTWriter.Bit32(timescale) ...	% Time scale
                        QTWriter.Bit32(duration) ...  	% Duration
                        0 0 ...                         % Language
                        0 0];                           % Playback quality
            len = 32;
        end
        
        function [atom,len]=mvhd_atom(time,timescale,duration)
            atom = [0 0 0 108 double('mvhd') ...      	% Atom Header
                        0 0 0 0 ...                    	% Version, Flags
                        QTWriter.Bit32(time) ...      	% Creation time
                        QTWriter.Bit32(time) ...      	% Modification time
                        QTWriter.Bit32(timescale) ...	% Time scale
                        QTWriter.Bit32(duration) ...   	% Duration 
                        0 1 0 0 ...                    	% Preferred rate
                        1 0 ...                       	% Preferred volume
                        0 0 0 0 0 0 0 0 0 0 ...       	% Reserved
                        0 1 0 0 0 0 0 0 0 0 0 0 ...    	% Matrix structure
                        0 0 0 0 0 1 0 0 0 0 0 0 ...
                        0 0 0 0 0 0 0 0 64 0 0 0 ...
                        0 0 0 0 ...                 	% Preview time
                        0 0 0 0 ...                   	% Preview duration
                        0 0 0 0 ...                   	% Poster time
                        0 0 0 0 ...                   	% Selection time
                        0 0 0 0 ...                   	% Selection duration
                        0 0 0 0 ...                   	% Current time
                        0 0 0 2];                   	% Next track ID
            len = 108;
        end
        
        function [atom,len]=stco_atom(framestarts)
            n = length(framestarts);
            len = 4*n+16;
            atom = [QTWriter.Bit32(len) double('stco') ...	% Atom header
                        0 0 0 0 ...                         % Version, Flags
                        QTWriter.Bit32(n) ...              	% Number of entries
                        QTWriter.Bit32(framestarts)];     	% Chunk offset table: Chunks
        end
        
        function [atom,len]=stsc_atom()
            atom = [0 0 0 28 double('stsc') ...	% Atom Header
                        0 0 0 0 ...           	% Version, Flags
                        0 0 0 1 ...             % Number of entries
                        0 0 0 1 ...             % Sample-to-chunk table: First chunk
                        0 0 0 1 ...             % Sample-to-chunk table: Samples per chunk
                        0 0 0 1];               % Sample-to-chunk table: Sample description ID
            len = 28;
        end
        
        function [atom,len]=stsd_atom(imageformatname,imagequality,...
                                      framewidth,frameheight,movieformatname,...
                                      bitdepth,colorspace,transparency)
            if transparency
                bitdepth = 4*bitdepth;
            else
                if strcmp(colorspace,'grayscale')
                    bitdepth = bitdepth+32;
                else
                    bitdepth = 3*bitdepth;
                end
            end
            v = double(any(strcmp(movieformatname,'Photo - JPEG')));
            atom = [0 0 0 102 double('stsd') ...                                    % Atom Header
                        0 0 0 0 ...                                                 % Version, Flags
                        0 0 0 1 ...                                                 % Number of entries
                            ...
                            0 0 0 86 double(imageformatname) ...                    % Atom Header
                                0 0 0 0 0 0 ...                                     % Reserved
                                0 1 ...                                             % Data reference index
                                0 v ...                                             % Version
                                0 v ...                                             % Revision level
                                double('appl') ...                                  % Vendor
                                0 0 3 255 ...                                      	% Temporal quality (perfect = 0 0 3 255)
                                QTWriter.Bit32(floor(10.24*imagequality)) ...    	% Spatial quality (perfect = 0 0 4 0)
                                QTWriter.Bit32(framewidth*65536+frameheight) ...	% Width, Height
                                0 72 0 0 ...                                        % Horizontal resolution (pixels/inch)
                                0 72 0 0 ...                                        % Vertical resolution (pixels/inch)
                                0 0 0 0 ...                                         % Data size
                                0 1 ...                                             % Frame count
                                length(movieformatname) ...                         % Compressor name byte count
                                double(movieformatname) ...                         % Compressor name
                                zeros(1,31-length(movieformatname)) ...             % Compressor name padding
                                0 bitdepth ...                                   	% Depth
                                255 255]; ...                                       % Color table ID
            len = 102;
        end
        
        function [atom,len]=stsz_atom(numberofframes,framelengths)
            len = 4*numberofframes+20;
            atom = [QTWriter.Bit32(len) double('stsz') ...	% Atom Header
                        0 0 0 0 ...                         % Version, Flags
                        0 0 0 0 ...                         % Sample size
                        QTWriter.Bit32(numberofframes) ... 	% Number of entries
                        QTWriter.Bit32(framelengths)];      % Sample size table: Samples
        end
        
        function [atom,len]=stts_atom(numberofframes,sampleduration)
            len = 8*numberofframes+16;
            ttstable = [ones(1,numberofframes);sampleduration];
            atom = [QTWriter.Bit32(len) double('stts') ... 	% Atom Header
                        0 0 0 0 ...                         % Version, Flags
                        QTWriter.Bit32(numberofframes) ... 	% Number of entries
                        QTWriter.Bit32(ttstable(:)')];     	% Time-to-sample table: Sample count, Sample duration
        end
        
        function [atom,len]=tapt_atom(framewidth,frameheight)
            width = QTWriter.Bit32(framewidth*65536);
            height = QTWriter.Bit32(frameheight*65536);
            atom = [0 0 0 68 double('tapt') ...   	% Atom Header
                        ...
                        0 0 0 20 double('clef') ...	% Atom Header
                            0 0 0 0 ...           	% Version, Flags
                            width ...               % Clean aperture width
                            height ...              % Clean aperture height
                        ...
                        0 0 0 20 double('prof') ...	% Atom Header
                            0 0 0 0 ...           	% Version, Flags
                            width ...               % Production aperture width
                            height ...              % Production aperture height
                        ...
                        0 0 0 20 double('enof') ...	% Atom Header
                            0 0 0 0 ...          	% Version, Flags
                            width ...               % Encoded width
                            height];                % Encoded height
            len = 68;
        end
        
        function [atom,len]=tkhd_atom(time,duration,framewidth,frameheight)
            atom = [0 0 0 92 double('tkhd') ...                 % Atom Header
                        0 0 0 15 ...                            % Version, Flags
                        QTWriter.Bit32(time) ...              	% Creation time
                        QTWriter.Bit32(time) ...              	% Modification time
                        0 0 0 1 ...                           	% Track ID
                        0 0 0 0 ...                             % Reserved
                        QTWriter.Bit32(duration) ...          	% Duration
                        0 0 0 0 0 0 0 0 ...                     % Reserved
                        0 0 ...                                 % Layer
                        0 0 ...                                 % Alternate group
                        0 0 ...                                 % Volume
                        0 0 ...                                 % Reserved
                        0 1 0 0 0 0 0 0 0 0 0 0 ...             % Matrix structure
                        0 0 0 0 0 1 0 0 0 0 0 0 ...
                        0 0 0 0 0 0 0 0 64 0 0 0 ...
                        QTWriter.Bit32(framewidth*65536) ...    % Track width
                        QTWriter.Bit32(frameheight*65536)];     % Track height
            len = 92;
        end
        
        function [atom,len]=udta_atom(movieloop,movieplayallframes)
            if strcmp(movieloop,'none')
                loopudta = [];
                loopudtalen = 0;
            else
                loopval = double(strcmp(movieloop,'backandforth'));
                loopudta = [0 0 0 12 double('LOOP') ...
                                0 0 0 loopval];
                loopudtalen = 12;
            end
            versionstring = ['Created with QTWriter for Matlab, '...
                             'Version 1.1, December 7, 2013, '...
                             'Andrew D. Horchler'];
            versionstringlen = length(versionstring);
            len = versionstringlen+loopudtalen+44;
            atom = [QTWriter.Bit32(len) double('udta') ...	% Atom Header
                        ...
                        QTWriter.Bit32(versionstringlen+8) double('©swr') ...
                            double(versionstring) ...
                            ...
                        0 0 0 19 double('©day') ...
                            double(date) ...
                            ...
                        loopudta ...
                            ...
                        0 0 0 9 double('AllF') ...
                            movieplayallframes];
        end
        
        function [atom,len]=vmhd_atom(transparency)
            if transparency
                gmode = [1 0];  % Straight alpha
            else
                gmode = [0 64]; % Dither copy
            end
            atom = [0 0 0 20 double('vmhd') ...	% Atom Header
                        0 0 0 1 ...            	% Version, Flags
                        gmode ...            	% Graphics mode
                        128 0 128 0 128 0];    	% Opcolor
            len = 20;
        end
        
        function [atom,len]=wide_atom()
            atom = [0 0 0 8 double('wide')];
            len = 8;
        end
        
    end
    
end