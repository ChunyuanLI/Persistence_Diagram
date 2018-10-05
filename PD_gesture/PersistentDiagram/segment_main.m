function segment_main()

    close all
    clear all;
    clc;
      
    addpath('PersistentDiagram\');
    addpath('codesPCA\');
    
    % selection of plot
    do_plot_hand = 0;
    do_plot_time_series = 0;
    do_plot_persistent = 0;
    
    % load DIR for certain dataset
    dataset_name = 'Gesture';
    load_DIRs;

    bmp_files = dir([Bmp_DIR,'*.bmp']);
    N_file = length(bmp_files);
    
    contour_files = dir([Contour_DIR,'*.mat']);
    %persistent_files = dir([Persistent_DIR,'*.mat']);
    
    time = [];
    
    for id_file = 1:N_file%1:N_file
      
        name = bmp_files(id_file).name;
        num_name = length(name);
        name = name(1,1:num_name-4);
        
        str = fprintf('Processing: index %d , name %s.\n',id_file, name);
        
        img_name = [Bmp_DIR,bmp_files(id_file).name];
        img = imread(img_name);
        
        coutour_name = [Contour_DIR,contour_files(id_file).name];
        load(coutour_name);
        
        num_vertices = size(hand_bounadry,1);
        
        img = 1-img;
      
        tic 
        dt_map = bwdist(img);
        
        [row_max_dt, col_idx] = max(dt_map);
        [max_dt, row_idx] = max(row_max_dt');
        
        % plot the hand image and its boundary representation
        if do_plot_hand == 1
            figure
            imshow(img);
            hold on
            plot(hand_bounadry(:,2),hand_bounadry(:,1),'--rs','LineWidth',2,...
                'MarkerEdgeColor','g',...
                'MarkerFaceColor','g',...
                'MarkerSize',4);
            hold on
            plot(row_idx,col_idx(row_idx),'ro');
            plot(hand_bounadry(1,2),hand_bounadry(1,1),'ko');
            hold off
        end
        
%         coordinate_start = [ mean([hand_bounadry(1,2),hand_bounadry(end,2)]),...
%             mean([hand_bounadry(1,1),hand_bounadry(end,1)])];
        
        coordinate_max_dt  = [row_idx,col_idx(row_idx)];
        coordinate_bounadry = [hand_bounadry(:,2),hand_bounadry(:,1)];
        
        % Center X by subtracting off column means
         X = coordinate_bounadry;
 
         [A,Z,variance,Tsquare]=princomp(X);
         
         coordinate_center = coordinate_max_dt;
         transformed_center = (coordinate_center-mean(X,1))*A;
         
        % testPCA(X);
        % plot(Z(:,1)/max_dt,1:num_vertices);        
        
        d2center = pdist2(transformed_center,Z);        
        d2center = d2center/max_dt;

        %% angle
        if 0 
        vectors = coordinate_bounadry - repmat(coordinate_max_dt, [num_vertices 1]);
        angles = atan2(-vectors(1, 1), vectors(1, 2)) - atan2(-vectors(:, 1), vectors(:, 2));
        relative_dis = sqrt(sum(vectors.^2, 2));
        % normalize...
        for i = 2:length(angles)
            if angles(i) - angles(i - 1) > pi
                angles(i) = angles(i) - 2 * pi;
            elseif angles(i) - angles(i - 1) < -pi
                angles(i) = angles(i) + 2 * pi;
            end
        end
        angles = (angles - min(angles)) / (max(angles) - min(angles));        
 
        end
        
        
        %% persistence
        S = zeros(num_vertices,5);
        Z = (Z-repmat(transformed_center,num_vertices,1))./max_dt;
        
        C1 = Z(:,1);
        S(:,1) = abs(C1);
        S(:,2) = abs(C1); %max(C1) - ( C1 - min(C1) );
        
        C2 = Z(:,2);
        S(:,3) = abs(C2);
        S(:,4) = abs(C2);%max(C2) - ( C2 - min(C2) );
        
        S(:,5) = d2center;
        
        
        % normalize the scalar function between 0 and 1
        if 0
            SS = [];
            num_f = size(S,2);
            for id_f = 1:num_f
               f =  S(:,num_f);
               f = (f - min(f))/(max(f)-min(f));
               SS = [SS, f];
            end 
            S = SS;
        end
             
%         angles = angles'.^(1/1);
%         d2center = d2center.^(1/1);
        % plot the time-series curve representation

        if do_plot_time_series == 1        
            figure
            %plot(angles,d2center.*angles);
            plot(1:num_vertices,d2center);
        end
        
        [vertices, edges,ringv] = generate_2d_shape_graph_structure(coordinate_bounadry);
        
        tau = 0.5;
        % scalar_value = d2center';
         scalar_value = S; %S(:,5);
        [LeefItem,LeefTable,Durations,Merged_forest] = Persistence_on_2d_shape(vertices,ringv,scalar_value, tau);
        
        %Duration = Durations{5};
        
        %signature = detect_fingers(coordinate_bounadry,angles,Duration,Merged_forest);
        
        if do_plot_persistent == 1
            min_coordinate = 0;
            max_coordinate = 3.5;        
            plotPD(Duration,min_coordinate,max_coordinate);
            %plotSegmentation(img, vertices,Merged_forest);
        end
        t = toc
        
        %time = [time,t];
        persistent_file = [name,'.mat'];
        persistent_name = [Persistent_Abs_DIR,persistent_file];
        % save(persistent_name,'signature');
        save(persistent_name,'Durations');
        
    end
    
end