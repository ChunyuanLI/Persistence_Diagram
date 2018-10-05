function Persistence_main()

    close all
    clear all;
    clc;
    
    addpath('PersistentDiagram/');
    Bmp_DIR = 'Data/Precise Masks/';
    Contour_DIR = 'Data/Boundaries/';    
    % selection of plot
    do_plot_hand = 1;
    do_plot_time_series = 1;
    do_plot_persistent = 1;
    
    % load DIR for certain dataset
    dataset_name = 'Gesture';
    load_DIRs; %% change data directory inside

    bmp_files = dir([Bmp_DIR,'*.bmp']);
    N_file = length(bmp_files);
    
    contour_files = dir([Contour_DIR,'*.mat']);
    
    time = [];
    
    for id_file = 737%1:N_file%1:N_file
      
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
                'MarkerSize',2);
            hold on
            plot(row_idx,col_idx(row_idx),'ro', 'MarkerEdgeColor','w',...
                'MarkerFaceColor','r',...
                'MarkerSize',8);
            plot(hand_bounadry(1,2),hand_bounadry(1,1),'ko', 'MarkerEdgeColor','k',...
                'MarkerFaceColor','y',...
                'MarkerSize',8);
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
        d2center = d2center/max_dt + 0.2;

        
        %% persistence



        % plot the time-series curve representation

        if do_plot_time_series == 1        
            figure
            %plot(angles,d2center.*angles);
            p = plot(1:num_vertices,d2center);
            xlabel('Vertex Index','fontsize',12)
            ylabel('Distance','fontsize',12)
            set(p,'Color','blue','LineWidth',3)
            xlim([0 num_vertices]) 
            ylim([0.8 3.5])
            set(gca,'fontsize',12);
        end
        
        [vertices, edges,ringv] = generate_2d_shape_graph_structure(coordinate_bounadry);
        
         tau = 0.5;
         % scalar_value = d2center';
         func = d2center;

        
        X = vertices(:,1);
        Y = vertices(:,2);
        plotRegions(X,Y,func);
         
        [LeefItem,LeefTable,Durations,Merged_forest] = Persistence_on_2d_shape(vertices,ringv,func', tau);
        
        Duration = Durations{1};
 
        if do_plot_persistent == 1
            min_coordinate = 0;
            max_coordinate = 3.5;        
            plotPD(Duration,min_coordinate,max_coordinate);
        end
        t = toc
       
        persistent_file = [name,'.mat'];
        persistent_name = [Persistent_Abs_DIR,persistent_file];
        
    end
    
end