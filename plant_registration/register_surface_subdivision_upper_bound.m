%REGISTER_VIA_SURFACE_SUBDIVISION Do a coarse to fine, recursive
%registration.
function [Y1,Y2,Y3] = ...
                    register_surface_subdivision_upper_bound( X,Y,iters_rigid,...
                                                      iters_nonrigid,lambda, beta,...
                                                      MIN_SIZE )
    
if nargin == 6
    MIN_SIZE = min(size(X,1),size(Y,1)) / 20
end
fgt = 0;
[Y1,Y2,Y3] = registerPoints( X,Y,iters_rigid,iters_nonrigid,lambda, beta,MIN_SIZE,fgt );
end    
 
function [X__,Y__,Z__] = registerPoints( X,Y,iters_rigid,iters_nonrigid,lambda, beta, MIN_SIZE,fgt )   
    scale = 0;
    if size(X,1) > MIN_SIZE && size(Y,1) > MIN_SIZE
       
        [Y1_,Y2_,Y3_,tr,tnr,cr] = registerToReferenceRangeScan(X, Y, iters_rigid, ...                                                iters_rigid,...
                                                           iters_nonrigid,...
                                                           lambda, beta, ...
                                                           fgt, scale );
        min_x = min( [ X(:,1);Y1_ ] )
        max_x = max( [ X(:,1);Y1_ ] )
        min_y = min( [ X(:,2);Y2_ ] )
        max_y = max( [ X(:,2);Y2_ ] )
        min_z = min( [ X(:,3);Y3_ ] )  
        max_z = max( [ X(:,3);Y3_ ] )
        
        width = sqrt( max_x^2 + min_x^2 )
        height = sqrt( max_y^2 + min_y^2 )
        depth = sqrt( max_z^2 + min_z^2 )
        %pad = 0.2;
        
        left_x   = min_x %- pad*width
        right_x  = max_x %+ pad*width
        top_x    = max_y %+ pad*height
        bottom_x = min_y %- pad*height
        back_x   = min_z %- pad*depth
        front_x  = max_z %+ pad*depth
        
        % this use of X co-ords as the dividing space is on purpose
        left_y   =  min_x %min(X(:,1))
        right_y  = max_x %max(X(:,1))
        top_y    = max_y %max(X(:,2))
        bottom_y = min_y %min(X(:,2))
        back_y   = min_z %min(X(:,3))
        front_y  = max_z %max(X(:,3))       
        
        %width_x = (right_x - left_x)/2
        %height_x = 
        m_width  = left_x+((right_x-left_x)/2)
        m_height = bottom_x+((top_x-bottom_x)/2)
        m_depth = back_x+((front_x-back_x)/2 )
        
        m_width_y  = left_y+((right_y-left_y)/2)
        m_height_y = bottom_y+((top_y-bottom_y)/2)
        m_depth_y = back_y+((front_y-back_y)/2 )
        
        X1_ = X(:,1);
        X2_ = X(:,2);
        X3_ = X(:,3);
        
        idx_x_000 = find( X1_ < m_width & X2_ < m_height & X3_ < m_depth );
        idx_x_001 = find( X1_ < m_width & X2_ < m_height & X3_ >= m_depth );
        idx_x_010 = find( X1_ < m_width & X2_ >= m_height & X3_ < m_depth );
        idx_x_011 = find( X1_ < m_width & X2_ >= m_height & X3_ >= m_depth );
        idx_x_100 = find( X1_ >= m_width & X2_ < m_height & X3_ < m_depth );
        idx_x_101 = find( X1_ >= m_width & X2_ < m_height & X3_ >= m_depth );
        idx_x_110 = find( X1_ >= m_width & X2_ >= m_height & X3_ < m_depth );
        idx_x_111 = find( X1_ >= m_width & X2_ >= m_height & X3_ >= m_depth );

        idx_y_000 = find( Y1_ < m_width_y & Y2_ < m_height_y & Y3_ < m_depth_y );
        idx_y_001 = find( Y1_ < m_width_y & Y2_ < m_height_y & Y3_ >= m_depth_y );
        idx_y_010 = find( Y1_ < m_width_y & Y2_ >= m_height_y & Y3_ < m_depth_y );
        idx_y_011 = find( Y1_ < m_width_y & Y2_ >= m_height_y & Y3_ >= m_depth_y );
        idx_y_100 = find( Y1_ >= m_width_y & Y2_ < m_height_y & Y3_ < m_depth_y );
        idx_y_101 = find( Y1_ >= m_width_y & Y2_ < m_height_y & Y3_ >= m_depth_y );
        idx_y_110 = find( Y1_ >= m_width_y & Y2_ >= m_height_y & Y3_ < m_depth_y );
        idx_y_111 = find( Y1_ >= m_width_y & Y2_ >= m_height_y & Y3_ >= m_depth_y );
        
        %make fgt = 0 for the smaller subdivisions
        [Y1_000,Y2_000,Y3_000] = registerPoints( X(idx_x_000,:),[Y1_(idx_y_000),Y2_(idx_y_000),Y3_(idx_y_000)],30,iters_nonrigid,lambda, beta, MIN_SIZE, 0 );
        [Y1_001,Y2_001,Y3_001] = registerPoints( X(idx_x_001,:),[Y1_(idx_y_001),Y2_(idx_y_001),Y3_(idx_y_001)],30,iters_nonrigid,lambda, beta, MIN_SIZE, 0 );
        [Y1_010,Y2_010,Y3_010] = registerPoints( X(idx_x_010,:),[Y1_(idx_y_010),Y2_(idx_y_010),Y3_(idx_y_010)],30,iters_nonrigid,lambda, beta, MIN_SIZE, 0 );
        [Y1_011,Y2_011,Y3_011] = registerPoints( X(idx_x_011,:),[Y1_(idx_y_011),Y2_(idx_y_011),Y3_(idx_y_011)],30,iters_nonrigid,lambda, beta, MIN_SIZE, 0 );
        [Y1_100,Y2_100,Y3_100] = registerPoints( X(idx_x_100,:),[Y1_(idx_y_100),Y2_(idx_y_100),Y3_(idx_y_100)],30,iters_nonrigid,lambda, beta, MIN_SIZE, 0 );
        [Y1_101,Y2_101,Y3_101] = registerPoints( X(idx_x_101,:),[Y1_(idx_y_101),Y2_(idx_y_101),Y3_(idx_y_101)],30,iters_nonrigid,lambda, beta, MIN_SIZE, 0 );
        [Y1_110,Y2_110,Y3_110] = registerPoints( X(idx_x_110,:),[Y1_(idx_y_110),Y2_(idx_y_110),Y3_(idx_y_110)],30,iters_nonrigid,lambda, beta, MIN_SIZE, 0 );
        [Y1_111,Y2_111,Y3_111] = registerPoints( X(idx_x_111,:),[Y1_(idx_y_111),Y2_(idx_y_111),Y3_(idx_y_111)],30,iters_nonrigid,lambda, beta, MIN_SIZE, 0 );

        X__ = [Y1_000; Y1_001 ; Y1_010 ; Y1_011 ; Y1_100 ; Y1_101 ; Y1_110 ; Y1_111 ]; 
        Y__ = [Y2_000; Y2_001 ; Y2_010 ; Y2_011 ; Y2_100 ; Y2_101 ; Y2_110 ; Y2_111 ];  
        Z__ = [Y3_000; Y3_001 ; Y3_010 ; Y3_011 ; Y3_100 ; Y3_101 ; Y3_110 ; Y3_111 ]; 
    else
        X__ = Y(:,1);
        Y__ = Y(:,2);
        Z__ = Y(:,3);
    end

end