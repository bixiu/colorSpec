
library( colorSpec )

#   reproduce Fig. 3(3.7) page 182 in Wyszecki & Stiles

plotChromaticityDiagram  <-  function( .xyz=xyz1931.1nm )
    {
    coredata    = coredata( .xyz )
    denom       = rowSums( coredata )
    x   = coredata[ ,1] / denom
    y   = coredata[ ,2] / denom    
    
    xylab   = tolower( substr(specnames(.xyz),1,1) )
    
    plot.default( range(x), range(y), type='n', las=1, xlab='', ylab='', asp=1, lab=c(10,8,7), tcl=0, mgp=c(3, 0.25, 0)  )
    title( xlab=xylab[1], line=1.5 )
    title( ylab=xylab[2], line=2 )    
    grid( lty=1 )
    abline( h=0, v=0 )    
    
    polygon( x, y, col='white' )
    
    #   put a black dot at white point
    denom   = colSums( coredata )
    xy      = denom[1:2] / sum(denom)
    points( xy[1], xy[2], pch=20 )
    
    return( TRUE )
    }
    
plotWavelengthPoints <- function( .obj )
    {
    wave    = wavelength(.obj)
    idx = which( wave %% 20 == 0 )
    
    if( length(idx) <= 1 )  return(FALSE)

    coredata    = coredata( .obj )
    denom       = rowSums( coredata )
    x   = coredata[ ,1] / denom
    y   = coredata[ ,2] / denom    
           
    xy      = cbind( x[idx], y[idx] )   #; print( xy )
    n       = nrow(xy)
    dist    = xy[ 2:n, ] - xy[1:(n-1), ]    #; print( dist )
    dist    = sqrt( rowSums(dist*dist) )    #; print( dist )
    idx     = idx[ 0.75*strheight("560") < dist ]
    
    points( x[idx], y[idx], pch=21, bg='white' )

    for( j in idx )
        {    
        tangent = c( x[j+1], y[j+1] ) - c( x[j], y[j] )
        normal  = c( -tangent[2], tangent[1] )
        normal  = normal / sqrt( sum(normal*normal) )
        adj     = -normal + c(0.4,0.5)
        text( x[j], y[j], as.character(wave[j]), adj=adj, cex=0.75 )
        }
        
    return(T)
    }

#   .obj        the colorSpec responder    "responsivity.material"
#   .data       as returned from computeOptimals()
plotOptimals <- function( .obj, .data )
    {
    plotChromaticityDiagram( .obj )

    grayvec = sort( unique(.data$gray) )
    
    for( gray in grayvec )
        {
        data_sub    = .data[ .data$gray == gray, ]
        
        denom   = rowSums( data_sub$optimal )
        x   = data_sub$optimal[ ,1] / denom
        y   = data_sub$optimal[ ,2] / denom
        
        polygon( x, y )
        
        idx = which.min( x + y )
        if( gray < 1 )
            # display as a percentage
            gray = 100 * gray

        text( x[idx], y[idx], sprintf( "%g", gray ), adj=c(-0.25,0), cex=0.6 )
        }
        
    plotWavelengthPoints( .obj )        
    
    return( invisible(TRUE) )
    }

computeOptimals <- function( .obj, .Ylevel=c( seq( 0.10, 0.90, by=0.1 ), 0.95 ), .angles=360 )
    {
    theta   = seq( 0, 360, len=.angles+1 )
    theta   = theta[ 1:.angles ] * pi/180
    direction   = cbind( cos(theta), 0, sin(theta) )    #; print( direction )

    out = NULL
    for( Y in .Ylevel )
        out = rbind( out, probeOptimalColors( .obj, Y, direction, aux=F ) )

    #   print( str(out) )
    
    return( out )
    }