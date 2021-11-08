PORTNAME=	jabref
PORTVERSION=	5.3
DISTVERSIONPREFIX=v
CATEGORIES=	print education java editors

MAINTAINER=	ports@FreeBSD.org
COMMENT=	BibTeX native bibliographic reference manager

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE.md

BUILD_DEPENDS=	gradle>=7.1.1:devel/gradle \
		openjfx14>0:java/openjfx14
RUN_DEPENDS=	openjfx14>0:java/openjfx14

USES=		desktop-file-utils
USE_GITHUB=	yes
USE_JAVA=	yes
JAVA_VERSION=	16
JAVA_BUILD=	yes
JAVA_RUN=	yes

DATADIR=	${JAVASHAREDIR}/${PORTNAME}
ICON=		${DATADIR}/${PORTNAME}-icon48x48.png

SUB_FILES=	${PORTNAME}.sh ${PORTNAME}.desktop

MAKE_ENV+=	JAVA_HOME=${JAVA_HOME} \
		JAVA_VERSION=${JAVA_VERSION}

# Gradle cache path must be absolute (see https://github.com/gradle/gradle/issues/1338)
GRADLE_HOME_BASE=/tmp
GRADLE_RUN=	${SETENV} ${MAKE_ENV} gradle \
		--gradle-user-home ${GRADLE_HOME_BASE}/gradle-${PORTNAME} \
		--no-daemon
post-patch:
	${REINPLACE_CMD} 's#LOCALBASE#${LOCALBASE}#g' \
		${WRKSRC}/build.gradle

do-build:
	@cd ${WRKSRC} && ${GRADLE_RUN} installDist

do-install:
	${MKDIR} ${STAGEDIR}${DATADIR} \
		${STAGEDIR}${DATADIR}/lib \
		${STAGEDIR}${DATADIR}/resources/main/org
	(cd ${WRKSRC}/build/install/JabRef/lib && ${COPYTREE_SHARE} . ${STAGEDIR}${DATADIR}/lib)
	(cd ${WRKSRC}/build/resources/main/org && ${COPYTREE_SHARE} . ${STAGEDIR}${DATADIR}/resources/main/org)
	${RM} ${STAGEDIR}${DATADIR}/lib/javafx-base-14-linux.jar

	${INSTALL_SCRIPT} ${WRKDIR}/${PORTNAME}.sh ${STAGEDIR}${PREFIX}/bin/${PORTNAME}
	${INSTALL_DATA} ${WRKSRC}/buildres/linux/JabRef.png ${STAGEDIR}${ICON}
	${INSTALL_DATA} ${WRKDIR}/${PORTNAME}.desktop ${STAGEDIR}${DESKTOPDIR}

.include <bsd.port.mk>
