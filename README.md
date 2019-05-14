# Helianthus
Un circuito buscador de luz que mediante el uso de un microcontrolador programado en assembler (8-bits) maneja dos motores stepper para mover una foto resistencia, formando una semiesfera captando el punto con mayor intensidad de luz. Luego de la ejecucion de la busqueda, regresa al punto con mayor luz y tiene un display de 7 segmentos para mostrar el valor encontrado, o como el valor encontrado por otro microcontrolador siempre que sea mayor o el numero asignado al equipo. Para la realizacion de este proyecto se usaron dos motores Stepper, dos integrados ULN2003, una fotoresistencia puesta en conjunto con una resistencia de IK ohmios y un display de 7 segmentos para los resultados.

Los materiales a utilizarse para esta prctica son los siguientes:
* Pic 16f877
* 2 Motores Stepper 5v DC.
* 2 capacitores de 22 mf
* 1 foto resistencia
* 2 protoboard
* Quemadora de PIC
* Fuente de voltaje
* Programador de PIC USB Cana KIT
* Pic Simulator
* Cristal de Cuarzo de 20 Mhz

## Movimiento de motores stepper
El motor Stepper o paso a paso es un motor que se mueve en distintos pasos durante su rotación. A continuación, se describe el algoritmo para el movimiento de los motores:
* Realiza una rotación de 21 grados aproximadamente en el eje X
* Realiza una rotación de 180 grados en el eje Y
* Regresa al punto inicial de Y
* Realizar nuevamente una rotacin en el eje X
* En cada movimiento almacenar el valor mximo de calor que obtiene la fotorresistencia

## Fotoresistencia
Una fotorresistencia es un componente elctrico, el cual posee una resistencia capaz de variar su magnitud al estar encontacto con distintas magnitudes de intensidad lumnica. Está conformado por una clula fotorreceptora y dos pastillas.

## Estimación de la cantidad de luz
Para este proyecto la fotorresistencia se mueve en sintona con el motor que rota en el eje X, de este modo cada vez que el motor hace su movimiento, la fotorresistencia va captando la luz y variando su valor. Se programa un puerto de entrada para recibir el valor de la fotorresistencia y al obtenerlo se obtiene los 10 bits, quitndole los ltimos 2 para poder transformar el valor a una escala decimal de 0-9. Para mostrarlo posteriormente en un display
## Reposicionar la fotoresistencia
Para esta fase del proyecto, en nuestro cdigo debemos de tener una variable donde almacenamos el valor actual leído y el valor anterior, hacemos una comparacin si es mayor el actual con el anterior y hacemos el cambio si es necesario. De esta manera siempre tenemos el valor mximo almacenado para posteriormente mostrarlo.