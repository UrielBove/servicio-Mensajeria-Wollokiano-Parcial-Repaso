object pepita {
  var energy = 100

  method energy() = energy

  method fly(minutes) {
    energy = energy - minutes * 3
  }
}
//punto 1
class Mensaje{
  var property emisor
  const tipoDeContenido = Texto

  method peso() = 5 + tipoDeContenido.peso() * 1.3

  method contieneTexto(texto) = emisor.contains(texto) or tipoDeContenido.contieneTexto(texto)
}

class Texto{
  const elTexto
  method peso() = elTexto.size()
  method contieneTexto(texto)= elTexto.contains(texto) 
}

class Audio{
  const duracion
  method peso() = duracion * 1.2
  method contieneTexto(texto) = false
}

class Imagen{
  var alto = 0
  var ancho = 0
  var property modoCompresion = originalCompres

  method cantPixelesTotal() = ancho * alto
  method peso() = modoCompresion.compresion(self.cantPixelesTotal()) * 2
  method contieneTexto(texto) = false
}

object originalCompres{
  method compresion(pixeles) = pixeles
}

class VariableCompres{
  const porcentaje

  method compresion(pixeles) = porcentaje * pixeles
}

object maximaCompres{
  method compresion(pixeles)= pixeles.min(10000)
}

class Gif inherits Imagen{
  const cuadros

  override method peso() = super() * cuadros
}

class Contacto{
  const usuarioEnviado

  method peso() = 3
  method contieneTexto(texto) = usuarioEnviado.contains(texto)
}



class Usuario{

  const property nombre
  var espacioEnMemoria 
  const chats = []
  const notificaciones = []

  method agregar(chat){chats.add(chat)}
  //
  method enviarMensaje(chat){
    chat.restricciones()
  }
  method espacioOcupado() = chats.sum({chat=>chat.espacioOcupado()})

  method tieneEspacioLibre(mensaje) = espacioEnMemoria >= self.espacioOcupado() + mensaje.peso()
  // punto 3
  method busquedaDeTexto(texto) = chats.filter({chat=>chat.contieneTexto(texto)})
  //punto 4
  method mensajesMasPesados() = chats.map({chat=>chat.mensajesMasPesados()})
//
  method agregarNotificacion(notificacion) = notificaciones.add(notificacion)
  method notisDeUnChat(chat) = notificaciones.filter({notificacion=>notificacion.chat() == chat})
  method leer(chat) {self.notisDeUnChat(chat).forEach({notificacion=>notificacion.leer()})} //4b

  method notificacionesSinLeer(chat) = notificaciones.filter({notificacion=>not(notificacion.leida())}) //4c
}

class Chat{
  const participantes = []
  const property mensajesEnviados = []

//2
  method enviar(mensaje){
    self.validarEnvio(mensaje)
    mensajesEnviados.add(mensaje)
    self.recibirNotificacion() //Punto 5
  }
  
  method validarEnvio(mensaje) = if(not(self.cumpleRestricciones(mensaje))){throw new DomainException(message = "No se cumplen restricciones")}

  method espacioOcupado() = mensajesEnviados.sum({mensaje=>mensaje.peso()})

  method participanteEnConver(mensaje) = participantes.contains(mensaje.emisor())
  method participantesTienenEspacio(mensaje) = participantes.all({usuario=>usuario.tieneEspacioLibre(mensaje)})

  method cumpleRestricciones(mensaje) = self.participanteEnConver(mensaje) and self.participantesTienenEspacio(mensaje)

  method agregarParticipante(usuario){participantes.add(usuario)}

  method contieneTexto(texto) = mensajesEnviados.any({mensaje=>mensaje.contieneTexto(texto)})

  method mensajesMasPesados() = mensajesEnviados.max({mensaje=>mensaje.peso()})

  method recibirNotificacion() = participantes.forEach({usuario=>usuario.agregarNotificacion(new Notificacion(chat = self))})
}

class ChatPremium inherits Chat{
  
  var creador
  var restriccionAd = difusion

  override method cumpleRestricciones(mensaje) = super(mensaje) and restriccionAd.restriccion(mensaje, self, creador)

}

object difusion{
  method restriccion(mensaje, chat, creador) = mensaje.emisor() == creador
}

object restringido{
  const limite = 100

  method restriccion(mensaje, chat, creador) =   chat.mensajesEnviados().size() < limite
}

object ahorro{
  const pesoMaximo = 100

   method restriccion(mensaje, chat, creador) = mensaje.peso() <= pesoMaximo
}

class Notificacion{
  var property leida = false
  const property chat

  method leer() {leida = true}
}