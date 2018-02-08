function commands=Gesture2Command(Gesture,commands)

    switch Gesture
        case 'Both Hands'
            commands(1)=1;
        case 'Right Hand'
            commands(2)=1;
        case 'Left Hand'
            commands(3)=1;
    end
            